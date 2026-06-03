%define height [ebp+8]
%define width [ebp+12]
%define frame1 [ebp+16]
%define frame2 [ebp+20]
%define frame_out [ebp+24]

section .text

; void merge_frames(int h,int w, unsigned char frame1[][w][3],unsigned char frame2[][w][3],unsigned char frame_out[][w][3]){
global merge_frames_simd

merge_frames_simd:

  push ebp
  mov ebp, esp
  push ebx

	pxor mm1, mm1
	movd mm1, height
	movd mm2, width
	pmuludq mm1, mm2
	mov eax, 3
	movd mm2, eax
	pmuludq mm1, mm2
	psrld mm1, 3
	movd ecx, mm1
	mov eax, frame1
	mov ebx, frame2
	mov edx, frame_out

loop:

	movq mm0, [eax]
	paddusb mm0, [ebx]
	movq [edx], mm0

  add eax, 8
  add ebx, 8
  add edx, 8

  loop loop

  pop ebx
  pop ebp
	ret
