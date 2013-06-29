; RUN: llc %s -o - | FileCheck %s

target triple = "vectorproc"

declare i32 @llvm.vectorproc.__builtin_vp_get_current_strand()
declare <16 x i32> @llvm.vectorproc.__builtin_vp_gather_loadi(<16 x i32> %a)
declare <16 x float> @llvm.vectorproc.__builtin_vp_gather_loadf(<16 x i32> %a)
declare <16 x i32> @llvm.vectorproc.__builtin_vp_gather_loadi_masked(<16 x i32> %a, i32 %mask)
declare <16 x float> @llvm.vectorproc.__builtin_vp_gather_loadf_masked(<16 x i32> %a, i32 %mask)
declare void @llvm.vectorproc.__builtin_vp_scatter_storei(<16 x i32> %ptr, 
	<16 x i32> %value)
declare void @llvm.vectorproc.__builtin_vp_scatter_storef(<16 x i32> %ptr, 
	<16 x float> %value)
declare void @llvm.vectorproc.__builtin_vp_scatter_storei_masked(<16 x i32> %ptr, 
	<16 x i32> %value, i32 %mask)
declare void @llvm.vectorproc.__builtin_vp_scatter_storef_masked(<16 x i32> %ptr, 
	<16 x float> %value, i32 %mask)
declare <16 x i32> @llvm.vectorproc.__builtin_vp_block_loadi_masked(<16 x i32>* %ptr, 
	i32 %mask)
declare <16 x float> @llvm.vectorproc.__builtin_vp_block_loadf_masked(<16 x i32>* %ptr, 
	i32 %mask)
declare void @llvm.vectorproc.__builtin_vp_block_storei_masked(<16 x i32>* %ptr, 
	<16 x i32> %value, i32 %mask)
declare void @llvm.vectorproc.__builtin_vp_block_storef_masked(<16 x i32>* %ptr, 
	<16 x float> %value, i32 %mask)

define i32 @get_current_strand() {	; CHECK: get_current_strand:
  %1 = call i32 @llvm.vectorproc.__builtin_vp_get_current_strand()
  ; CHECK: s{{[0-9]+}} = cr0

  ret i32 %1
}

define <16 x i32> @gather_loadi(<16 x i32> %ptr) {	; CHECK: gather_loadi:
entry:
  %0 = call <16 x i32> @llvm.vectorproc.__builtin_vp_gather_loadi(<16 x i32> %ptr)
  ; CHECK: v{{[0-9]+}} = mem_l[v0]

  ret <16 x i32> %0
}

define <16 x float> @gather_loadf(<16 x i32> %ptr) {	; CHECK: gather_loadf:
  %1 = call <16 x float> @llvm.vectorproc.__builtin_vp_gather_loadf(<16 x i32> %ptr)
  ; CHECK: vf{{[0-9]+}} = mem_l[v0]

  ret <16 x float> %1
}

define <16 x i32> @gather_loadi_masked(<16 x i32> %ptr, i32 %mask) { ; CHECK: gather_loadi_masked:
entry:
  %0 = call <16 x i32> @llvm.vectorproc.__builtin_vp_gather_loadi_masked(<16 x i32> %ptr, i32 %mask)
  ; CHECK: v{{[0-9]+}}{s0} = mem_l[v0]

  ret <16 x i32> %0
}

define <16 x float> @gather_loadf_masked(<16 x i32> %ptr, i32 %mask) {	; CHECK: gather_loadf_masked:
  %1 = call <16 x float> @llvm.vectorproc.__builtin_vp_gather_loadf_masked(<16 x i32> %ptr, i32 %mask)
  ; CHECK: vf{{[0-9]+}}{s0} = mem_l[v0]

  ret <16 x float> %1
}

define void @scatter_storei(<16 x i32> %ptr, <16 x i32> %value) { ; CHECK: scatter_storei:
  call void @llvm.vectorproc.__builtin_vp_scatter_storei(<16 x i32> %ptr, <16 x i32> %value)
  ; CHECK: mem_l[v0] = v1

  ret void
}

define void @scatter_storef(<16 x i32> %ptr, <16 x float> %value) { ; CHECK: scatter_storef:
  call void @llvm.vectorproc.__builtin_vp_scatter_storef(<16 x i32> %ptr, <16 x float> %value)
  ; CHECK: mem_l[v0] = v1

  ret void
}

define void @scatter_storei_masked(<16 x i32> %ptr, <16 x i32> %value, i32 %mask) { ; CHECK: scatter_storei_masked:
  call void @llvm.vectorproc.__builtin_vp_scatter_storei_masked(<16 x i32> %ptr, <16 x i32> %value, i32 %mask)
  ; CHECK: mem_l[v0]{s0} = v1

  ret void
}

define void @scatter_storef_masked(<16 x i32> %ptr, <16 x float> %value, i32 %mask) { ; CHECK: scatter_storef_masked:
  call void @llvm.vectorproc.__builtin_vp_scatter_storef_masked(<16 x i32> %ptr, <16 x float> %value, i32 %mask)
  ; CHECK: mem_l[v0]{s0} = v1

  ret void
}

define <16 x i32> @test_block_loadi_masked(<16 x i32>* %ptr, i32 %mask) {
	%result = call <16 x i32> @llvm.vectorproc.__builtin_vp_block_loadi_masked(
		<16 x i32>* %ptr, i32 %mask)
	; CHECK: v{{[0-9]+}}{s1} = mem_l[s0]

	ret <16 x i32> %result
}

define <16 x float> @test_block_loadf_masked(<16 x i32>* %ptr, i32 %mask) {
	%result = call <16 x float> @llvm.vectorproc.__builtin_vp_block_loadf_masked(
		<16 x i32>* %ptr, i32 %mask)
	; CHECK: vf{{[0-9]+}}{s1} = mem_l[s0]

	ret <16 x float> %result
}

define void @test_block_storei_masked(<16 x i32>* %ptr, <16 x i32> %value, i32 %mask) {
  call void @llvm.vectorproc.__builtin_vp_block_storei_masked(<16 x i32>* %ptr, 
  	<16 x i32> %value, i32 %mask)
  ; CHECK: mem_l[s0]{s1} = v0

  ret void
}

define void @test_block_storef_masked(<16 x i32>* %ptr, <16 x float> %value, i32 %mask) {
  call void @llvm.vectorproc.__builtin_vp_block_storef_masked(<16 x i32>* %ptr, 
  	<16 x float> %value, i32 %mask)
  ; CHECK: mem_l[s0]{s1} = v0

  ret void
}

