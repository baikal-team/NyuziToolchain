; RUN: llc %s -o - | FileCheck %s

target triple = "nyuzi-elf-none"

;
; Regression test for issue #11. The following code was causing an assertion:
; Assertion failed: (BestRC && "Couldn't find the register class"), function getMinimalPhysRegClass,
;      file NyuziToolchain/lib/CodeGen/TargetRegisterInfo.cpp, line 124.
; The problem was never directly fixed, but went away when the call to
; "setSchedulingPreference(Sched::RegPressure)" was removed from NyuziTargetLowering.
;

declare void @printf(i8* nocapture readonly, ...)

@.str = private unnamed_addr constant [13 x i8] c"swap %d %d: \00", align 1

define void @bad(i32 %i) {
  %rem = srem i32 13, %i
  tail call void (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str, i32 0, i32 0), i32 %i, i32 %rem)

	; CHECK: move s0, 13
	; CHECK: call __modsi3
	; CHECK: load_32 s1, .LCPI
	; CHECK: store_32 s1, (sp)
	; CHECK: store_32 s0, 8(sp)
	; CHECK: call printf

  ret void
}

