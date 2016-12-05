//===-- LoopSink.cpp - Loop Sink Pass ------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass does the inverse transformation of what LICM does.
// It traverses all of the instructions in the loop's preheader and sinks
// them to the loop body where frequency is lower than the loop's preheader.
// This pass is a reverse-transformation of LICM. It differs from the Sink
// pass in the following ways:
//
// * It only handles sinking of instructions from the loop's preheader to the
//   loop's body
// * It uses alias set tracker to get more accurate alias info
// * It uses block frequency info to find the optimal sinking locations
//
// Overall algorithm:
//
// For I in Preheader:
//   InsertBBs = BBs that uses I
//   For BB in sorted(LoopBBs):
//     DomBBs = BBs in InsertBBs that are dominated by BB
//     if freq(DomBBs) > freq(BB)
//       InsertBBs = UseBBs - DomBBs + BB
//   For BB in InsertBBs:
//     Insert I at BB's beginning
//===----------------------------------------------------------------------===//

#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AliasSetTracker.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/Loads.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Analysis/LoopPassManager.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionAliasAnalysis.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Metadata.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
using namespace llvm;

#define DEBUG_TYPE "loopsink"

STATISTIC(NumLoopSunk, "Number of instructions sunk into loop");
STATISTIC(NumLoopSunkCloned, "Number of cloned instructions sunk into loop");

static cl::opt<unsigned> SinkFrequencyPercentThreshold(
    "sink-freq-percent-threshold", cl::Hidden, cl::init(90),
    cl::desc("Do not sink instructions that require cloning unless they "
             "execute less than this percent of the time."));

static cl::opt<unsigned> MaxNumberOfUseBBsForSinking(
    "max-uses-for-sinking", cl::Hidden, cl::init(30),
    cl::desc("Do not sink instructions that have too many uses."));

/// Return adjusted total frequency of \p BBs.
///
/// * If there is only one BB, sinking instruction will not introduce code
///   size increase. Thus there is no need to adjust the frequency.
/// * If there are more than one BB, sinking would lead to code size increase.
///   In this case, we add some "tax" to the total frequency to make it harder
///   to sink. E.g.
///     Freq(Preheader) = 100
///     Freq(BBs) = sum(50, 49) = 99
///   Even if Freq(BBs) < Freq(Preheader), we will not sink from Preheade to
///   BBs as the difference is too small to justify the code size increase.
///   To model this, The adjusted Freq(BBs) will be:
///     AdjustedFreq(BBs) = 99 / SinkFrequencyPercentThreshold%
static BlockFrequency adjustedSumFreq(SmallPtrSetImpl<BasicBlock *> &BBs,
                                      BlockFrequencyInfo &BFI) {
  BlockFrequency T = 0;
  for (BasicBlock *B : BBs)
    T += BFI.getBlockFreq(B);
  if (BBs.size() > 1)
    T /= BranchProbability(SinkFrequencyPercentThreshold, 100);
  return T;
}

/// Return a set of basic blocks to insert sinked instructions.
///
/// The returned set of basic blocks (BBsToSinkInto) should satisfy:
///
/// * Inside the loop \p L
/// * For each UseBB in \p UseBBs, there is at least one BB in BBsToSinkInto
///   that domintates the UseBB
/// * Has minimum total frequency that is no greater than preheader frequency
///
/// The purpose of the function is to find the optimal sinking points to
/// minimize execution cost, which is defined as "sum of frequency of
/// BBsToSinkInto".
/// As a result, the returned BBsToSinkInto needs to have minimum total
/// frequency.
/// Additionally, if the total frequency of BBsToSinkInto exceeds preheader
/// frequency, the optimal solution is not sinking (return empty set).
///
/// \p ColdLoopBBs is used to help find the optimal sinking locations.
/// It stores a list of BBs that is:
///
/// * Inside the loop \p L
/// * Has a frequency no larger than the loop's preheader
/// * Sorted by BB frequency
///
/// The complexity of the function is O(UseBBs.size() * ColdLoopBBs.size()).
/// To avoid expensive computation, we cap the maximum UseBBs.size() in its
/// caller.
static SmallPtrSet<BasicBlock *, 2>
findBBsToSinkInto(const Loop &L, const SmallPtrSetImpl<BasicBlock *> &UseBBs,
                  const SmallVectorImpl<BasicBlock *> &ColdLoopBBs,
                  DominatorTree &DT, BlockFrequencyInfo &BFI) {
  SmallPtrSet<BasicBlock *, 2> BBsToSinkInto;
  if (UseBBs.size() == 0)
    return BBsToSinkInto;

  BBsToSinkInto.insert(UseBBs.begin(), UseBBs.end());
  SmallPtrSet<BasicBlock *, 2> BBsDominatedByColdestBB;

  // For every iteration:
  //   * Pick the ColdestBB from ColdLoopBBs
  //   * Find the set BBsDominatedByColdestBB that satisfy:
  //     - BBsDominatedByColdestBB is a subset of BBsToSinkInto
  //     - Every BB in BBsDominatedByColdestBB is dominated by ColdestBB
  //   * If Freq(ColdestBB) < Freq(BBsDominatedByColdestBB), remove
  //     BBsDominatedByColdestBB from BBsToSinkInto, add ColdestBB to
  //     BBsToSinkInto
  for (BasicBlock *ColdestBB : ColdLoopBBs) {
    BBsDominatedByColdestBB.clear();
    for (BasicBlock *SinkedBB : BBsToSinkInto)
      if (DT.dominates(ColdestBB, SinkedBB))
        BBsDominatedByColdestBB.insert(SinkedBB);
    if (BBsDominatedByColdestBB.size() == 0)
      continue;
    if (adjustedSumFreq(BBsDominatedByColdestBB, BFI) >
        BFI.getBlockFreq(ColdestBB)) {
      for (BasicBlock *DominatedBB : BBsDominatedByColdestBB) {
        BBsToSinkInto.erase(DominatedBB);
      }
      BBsToSinkInto.insert(ColdestBB);
    }
  }

  // If the total frequency of BBsToSinkInto is larger than preheader frequency,
  // do not sink.
  if (adjustedSumFreq(BBsToSinkInto, BFI) >
      BFI.getBlockFreq(L.getLoopPreheader()))
    BBsToSinkInto.clear();
  return BBsToSinkInto;
}

// Sinks \p I from the loop \p L's preheader to its uses. Returns true if
// sinking is successful.
// \p LoopBlockNumber is used to sort the insertion blocks to ensure
// determinism.
static bool sinkInstruction(Loop &L, Instruction &I,
                            const SmallVectorImpl<BasicBlock *> &ColdLoopBBs,
                            const SmallDenseMap<BasicBlock *, int, 16> &LoopBlockNumber,
                            LoopInfo &LI, DominatorTree &DT,
                            BlockFrequencyInfo &BFI) {
  // Compute the set of blocks in loop L which contain a use of I.
  SmallPtrSet<BasicBlock *, 2> BBs;
  for (auto &U : I.uses()) {
    Instruction *UI = cast<Instruction>(U.getUser());
    // We cannot sink I to PHI-uses.
    if (dyn_cast<PHINode>(UI))
      return false;
    // We cannot sink I if it has uses outside of the loop.
    if (!L.contains(LI.getLoopFor(UI->getParent())))
      return false;
    BBs.insert(UI->getParent());
  }

  // findBBsToSinkInto is O(BBs.size() * ColdLoopBBs.size()). We cap the max
  // BBs.size() to avoid expensive computation.
  // FIXME: Handle code size growth for min_size and opt_size.
  if (BBs.size() > MaxNumberOfUseBBsForSinking)
    return false;

  // Find the set of BBs that we should insert a copy of I.
  SmallPtrSet<BasicBlock *, 2> BBsToSinkInto =
      findBBsToSinkInto(L, BBs, ColdLoopBBs, DT, BFI);
  if (BBsToSinkInto.empty())
    return false;

  // Copy the final BBs into a vector and sort them using the total ordering
  // of the loop block numbers as iterating the set doesn't give a useful
  // order. No need to stable sort as the block numbers are a total ordering.
  SmallVector<BasicBlock *, 2> SortedBBsToSinkInto;
  SortedBBsToSinkInto.insert(SortedBBsToSinkInto.begin(), BBsToSinkInto.begin(),
                             BBsToSinkInto.end());
  std::sort(SortedBBsToSinkInto.begin(), SortedBBsToSinkInto.end(),
            [&](BasicBlock *A, BasicBlock *B) {
              return *LoopBlockNumber.find(A) < *LoopBlockNumber.find(B);
            });

  BasicBlock *MoveBB = *SortedBBsToSinkInto.begin();
  // FIXME: Optimize the efficiency for cloned value replacement. The current
  //        implementation is O(SortedBBsToSinkInto.size() * I.num_uses()).
  for (BasicBlock *N : SortedBBsToSinkInto) {
    if (N == MoveBB)
      continue;
    // Clone I and replace its uses.
    Instruction *IC = I.clone();
    IC->setName(I.getName());
    IC->insertBefore(&*N->getFirstInsertionPt());
    // Replaces uses of I with IC in N
    for (Value::use_iterator UI = I.use_begin(), UE = I.use_end(); UI != UE;) {
      Use &U = *UI++;
      auto *I = cast<Instruction>(U.getUser());
      if (I->getParent() == N)
        U.set(IC);
    }
    // Replaces uses of I with IC in blocks dominated by N
    replaceDominatedUsesWith(&I, IC, DT, N);
    DEBUG(dbgs() << "Sinking a clone of " << I << " To: " << N->getName()
                 << '\n');
    NumLoopSunkCloned++;
  }
  DEBUG(dbgs() << "Sinking " << I << " To: " << MoveBB->getName() << '\n');
  NumLoopSunk++;
  I.moveBefore(&*MoveBB->getFirstInsertionPt());

  return true;
}

/// Sinks instructions from loop's preheader to the loop body if the
/// sum frequency of inserted copy is smaller than preheader's frequency.
static bool sinkLoopInvariantInstructions(Loop &L, AAResults &AA, LoopInfo &LI,
                                          DominatorTree &DT,
                                          BlockFrequencyInfo &BFI,
                                          ScalarEvolution *SE) {
  BasicBlock *Preheader = L.getLoopPreheader();
  if (!Preheader)
    return false;

  // Enable LoopSink only when runtime profile is available.
  // With static profile, the sinking decision may be sub-optimal.
  if (!Preheader->getParent()->getEntryCount())
    return false;

  const BlockFrequency PreheaderFreq = BFI.getBlockFreq(Preheader);
  // If there are no basic blocks with lower frequency than the preheader then
  // we can avoid the detailed analysis as we will never find profitable sinking
  // opportunities.
  if (all_of(L.blocks(), [&](const BasicBlock *BB) {
        return BFI.getBlockFreq(BB) > PreheaderFreq;
      }))
    return false;

  bool Changed = false;
  AliasSetTracker CurAST(AA);

  // Compute alias set.
  for (BasicBlock *BB : L.blocks())
    CurAST.add(*BB);

  // Sort loop's basic blocks by frequency
  SmallVector<BasicBlock *, 10> ColdLoopBBs;
  SmallDenseMap<BasicBlock *, int, 16> LoopBlockNumber;
  int i = 0;
  for (BasicBlock *B : L.blocks())
    if (BFI.getBlockFreq(B) < BFI.getBlockFreq(L.getLoopPreheader())) {
      ColdLoopBBs.push_back(B);
      LoopBlockNumber[B] = ++i;
    }
  std::stable_sort(ColdLoopBBs.begin(), ColdLoopBBs.end(),
                   [&](BasicBlock *A, BasicBlock *B) {
                     return BFI.getBlockFreq(A) < BFI.getBlockFreq(B);
                   });

  // Traverse preheader's instructions in reverse order becaue if A depends
  // on B (A appears after B), A needs to be sinked first before B can be
  // sinked.
  for (auto II = Preheader->rbegin(), E = Preheader->rend(); II != E;) {
    Instruction *I = &*II++;
    if (!L.hasLoopInvariantOperands(I) ||
        !canSinkOrHoistInst(*I, &AA, &DT, &L, &CurAST, nullptr))
      continue;
    if (sinkInstruction(L, *I, ColdLoopBBs, LoopBlockNumber, LI, DT, BFI))
      Changed = true;
  }

  if (Changed && SE)
    SE->forgetLoopDispositions(&L);
  return Changed;
}

namespace {
struct LegacyLoopSinkPass : public LoopPass {
  static char ID;
  LegacyLoopSinkPass() : LoopPass(ID) {
    initializeLegacyLoopSinkPassPass(*PassRegistry::getPassRegistry());
  }

  bool runOnLoop(Loop *L, LPPassManager &LPM) override {
    if (skipLoop(L))
      return false;

    auto *SE = getAnalysisIfAvailable<ScalarEvolutionWrapperPass>();
    return sinkLoopInvariantInstructions(
        *L, getAnalysis<AAResultsWrapperPass>().getAAResults(),
        getAnalysis<LoopInfoWrapperPass>().getLoopInfo(),
        getAnalysis<DominatorTreeWrapperPass>().getDomTree(),
        getAnalysis<BlockFrequencyInfoWrapperPass>().getBFI(),
        SE ? &SE->getSE() : nullptr);
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<BlockFrequencyInfoWrapperPass>();
    getLoopAnalysisUsage(AU);
  }
};
}

char LegacyLoopSinkPass::ID = 0;
INITIALIZE_PASS_BEGIN(LegacyLoopSinkPass, "loop-sink", "Loop Sink", false,
                      false)
INITIALIZE_PASS_DEPENDENCY(LoopPass)
INITIALIZE_PASS_DEPENDENCY(BlockFrequencyInfoWrapperPass)
INITIALIZE_PASS_END(LegacyLoopSinkPass, "loop-sink", "Loop Sink", false, false)

Pass *llvm::createLoopSinkPass() { return new LegacyLoopSinkPass(); }
