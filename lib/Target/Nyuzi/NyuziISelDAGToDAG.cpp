//===-- NyuziISelDAGToDAG.cpp - A dag to dag inst selector for Nyuzi ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass transforms target independent LLVM DAG nodes into platform
// dependent nodes that map, for the most part, directly to target instructions.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "nyuzi-isel"

#include "NyuziTargetMachine.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
class NyuziDAGToDAGISel : public SelectionDAGISel {
public:
  explicit NyuziDAGToDAGISel(NyuziTargetMachine &tm) : SelectionDAGISel(tm) {}

  void Select(SDNode *N) override;

  bool SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintCode,
                                    std::vector<SDValue> &OutOps) override;

  // Complex Pattern Selectors (referenced from TableGen'd instruction matching
  // code)
  bool SelectADDRri(SDValue N, SDValue &Base, SDValue &Offset);

  const char *getPassName() const override {
    return "Nyuzi DAG->DAG Pattern Instruction Selection";
  }

// Include the pieces autogenerated from the target description.
#include "NyuziGenDAGISel.inc"
};
} // end anonymous namespace

bool NyuziDAGToDAGISel::SelectADDRri(SDValue Addr, SDValue &Base,
                                     SDValue &Offset) {
  if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
    Offset = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i32);
    return true;
  }
  if (Addr.getOpcode() == ISD::TargetExternalSymbol ||
      Addr.getOpcode() == ISD::TargetGlobalAddress)
    return false; // direct calls.

  if (Addr.getOpcode() == ISD::ADD) {
    if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1))) {
      if (isInt<13>(CN->getSExtValue())) {
        if (FrameIndexSDNode *FIN =
                dyn_cast<FrameIndexSDNode>(Addr.getOperand(0))) {
          // Constant offset from frame ref.
          Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
        } else {
          Base = Addr.getOperand(0);
        }
        Offset = CurDAG->getTargetConstant(CN->getZExtValue(), SDLoc(Addr),
                                           MVT::i32);
        return true;
      }
    }
  }
  Base = Addr;
  Offset = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i32);
  return true;
}

void NyuziDAGToDAGISel::Select(SDNode *N) {
  if (N->isMachineOpcode())
    return; // Already selected.

  SelectCode(N);
}

/// SelectInlineAsmMemoryOperand - Implement addressing mode selection for
/// inline asm expressions.
bool NyuziDAGToDAGISel::SelectInlineAsmMemoryOperand(
    const SDValue &Op, unsigned ConstraintCode, std::vector<SDValue> &OutOps) {
  SDValue Op0, Op1;
  switch (ConstraintCode) {
  default:
    return true;
  case 'm': // memory
    SelectADDRri(Op, Op0, Op1);
    break;
  }

  OutOps.push_back(Op0);
  OutOps.push_back(Op1);
  return false;
}

FunctionPass *llvm::createNyuziISelDag(NyuziTargetMachine &TM) {
  return new NyuziDAGToDAGISel(TM);
}
