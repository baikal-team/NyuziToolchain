# REQUIRES: ppc
# RUN: llvm-mc -filetype=obj -triple=powerpc64le-unknown-linux %s -o %t.o
# RUN: llvm-readobj -relocations %t.o | FileCheck -check-prefix=RELOCS %s
# RUN: ld.lld %t.o -o %t2
# RUN: llvm-objdump -D %t2 | FileCheck %s

# Make sure we calculate the offset correctly for a toc-relative access to a
# global variable as described by the PPC64 Elf V2 abi.
.abiversion 2

#  int global_a = 55
   .globl      global_a
   .section    ".data"
   .align      2
   .type       global_a, @object
   .size       global_a, 4
   .p2align    2
global_a:
   .long   41


   .section        ".text"
   .align 2
   .global _start
   .type   _start, @function
_start:
.Lfunc_gep0:
    addis 2, 12, .TOC.-.Lfunc_gep0@ha
    addi 2, 2, .TOC.-.Lfunc_gep0@l
.Lfunc_lep0:
    .localentry _start, .Lfunc_lep0-.Lfunc_gep0

    addis 3, 2, global_a@toc@ha
    addi 3, 3, global_a@toc@l
    li 0,1
    lwa 3, 0(3)
    sc
.size   _start,.-_start

# Verify the relocations that get emitted for the global variable are the
# expected ones.
# RELOCS:      Relocations [
# RELOCS-NEXT:   .rela.text {
# RELOCS:          0x8 R_PPC64_TOC16_HA global_a 0x0
# RELOCS:          0xC R_PPC64_TOC16_LO global_a 0x0

# Want to check _start for the values used to build the offset from the TOC base
# to global_a. The .TOC. symbol is expected at address 0x10030000, and the
# TOC base is address-of(.TOC.) + 0x8000.  The expected offset is:
# 0x10020000(global_a) - 0x10038000(Toc base) = -0x18000(Offset)
# which gets materialized into r3 as ((-1 << 16) - 32768).

# CHECK:      Disassembly of section .text:
# CHECK-NEXT: _start:
# CHECK:      10010008:       ff ff 62 3c     addis 3, 2, -1
# CHECK-NEXT: 1001000c:       00 80 63 38     addi 3, 3, -32768

# CHECK:      Disassembly of section .data:
# CHECK-NEXT: global_a:
# CHECK-NEXT: 10020000:       29 00 00 00

# CHECK:      Disassembly of section .got:
# CHECK-NEXT: .got:
# CHECK-NEXT: 10030000:       00 80 03 10
