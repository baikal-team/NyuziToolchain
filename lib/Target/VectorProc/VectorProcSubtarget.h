//===-- VectorProcSubtarget.h - Define Subtarget for the VECTORPROC -------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the VECTORPROC specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef VECTORPROC_SUBTARGET_H
#define VECTORPROC_SUBTARGET_H

#include "llvm/Target/TargetSubtargetInfo.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "VectorProcGenSubtargetInfo.inc"

namespace llvm {
class StringRef;

class VectorProcSubtarget : public VectorProcGenSubtargetInfo {
  virtual void anchor();
  
public:
  VectorProcSubtarget(const std::string &TT, const std::string &CPU,
                 const std::string &FS);

  /// ParseSubtargetFeatures - Parses features string setting specified 
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);
  
  std::string getDataLayout() const {
    const char *p;
    p = "e-p:32:32:32-i32:32:32-f32:32:32";
    return std::string(p);
  }

  int64_t getStackPointerBias() const {
    return 0;
  }
};

} // end namespace llvm

#endif
