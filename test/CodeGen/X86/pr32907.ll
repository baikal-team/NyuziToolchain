; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE42
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx512f | FileCheck %s --check-prefix=AVX --check-prefix=AVX512

define <2 x i64> @PR32907(<2 x i64> %astype.i, <2 x i64> %astype6.i) {
; SSE-LABEL: PR32907:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    psubq %xmm1, %xmm0
; SSE-NEXT:    movdqa %xmm0, %xmm1
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[1,1,3,3]
; SSE-NEXT:    pxor %xmm1, %xmm1
; SSE-NEXT:    psubq %xmm0, %xmm1
; SSE-NEXT:    pand %xmm2, %xmm1
; SSE-NEXT:    pandn %xmm0, %xmm2
; SSE-NEXT:    por %xmm2, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX2-LABEL: PR32907:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpsubq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsrad $31, %xmm0, %xmm1
; AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpsubq %xmm0, %xmm2, %xmm2
; AVX2-NEXT:    vpandn %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: PR32907:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vpsubq %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsraq $63, %zmm0, %zmm1
; AVX512-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512-NEXT:    vpsubq %xmm0, %xmm2, %xmm2
; AVX512-NEXT:    vpandn %xmm0, %xmm1, %xmm0
; AVX512-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX512-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
entry:
  %sub13.i = sub <2 x i64> %astype.i, %astype6.i
  %x.lobit.i.i = ashr <2 x i64> %sub13.i, <i64 63, i64 63>
  %sub.i.i = sub <2 x i64> zeroinitializer, %sub13.i
  %0 = xor <2 x i64> %x.lobit.i.i, <i64 -1, i64 -1>
  %1 = and <2 x i64> %sub13.i, %0
  %2 = and <2 x i64> %x.lobit.i.i, %sub.i.i
  %cond.i.i = or <2 x i64> %1, %2
  ret <2 x i64> %cond.i.i
}
