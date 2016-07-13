; RUN: llc %s -o - | FileCheck %s

target triple = "nyuzi-elf-none"

define i32 @test_sext8(i8 %v) {      ; CHECK: test_sext8
  %tmp1 = sext i8 %v to i32

  ; CHECK: sext_8 s0, s0

  ret i32 %tmp1
}

define i32 @test_zext8(i8 %v) {     ; CHECK: test_zext8
  %tmp1 = zext i8 %v to i32

  ; CHECK: and s0, s0, 255

  ret i32 %tmp1
}

define i32 @test_sext16(i16 %v) {    ; CHECK: test_sext16
  %tmp1 = sext i16 %v to i32

  ; CHECK: sext_16 s0, s0

  ret i32 %tmp1
}

define i32 @test_zext16(i16 %v) {    ; CHECK: test_zext16
  %tmp1 = zext i16 %v to i32

  ; The mask is large enough that it needs to be loaded from the constant pool.
  ; and s0, s0, s{{[0-9]+}}

  ret i32 %tmp1
}
