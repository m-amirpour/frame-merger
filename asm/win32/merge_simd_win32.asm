%define height    dword [ebp+8]
%define width     dword [ebp+12]
%define frame1    dword [ebp+16]
%define frame2    dword [ebp+20]
%define frame_out dword [ebp+24]

section .text

global _merge_frames_simd
_merge_frames_simd:

    push ebp
    mov  ebp, esp

    push ebx
    push esi
    push edi

    ; total_bytes = h * w * 3
    mov eax, height
    imul eax, width
    imul eax, 3

    mov ecx, eax
    shr ecx, 3          ; /8 chunks

    mov esi, frame1
    mov ebx, frame2
    mov edi, frame_out

.loop:
    test ecx, ecx
    jz .tail

    movq mm0, [esi]
    paddusb mm0, [ebx]
    movq [edi], mm0

    add esi, 8
    add ebx, 8
    add edi, 8

    dec ecx
    jmp .loop

.tail:
    mov eax, height
    imul eax, width
    imul eax, 3
    and eax, 7

    jz .done

.tail_loop:
    mov dl, [esi]
    add dl, [ebx]
    jc .sat

    mov [edi], dl
    jmp .next

.sat:
    mov byte [edi], 255

.next:
    inc esi
    inc ebx
    inc edi

    dec eax
    jnz .tail_loop

.done:
    emms

    pop edi
    pop esi
    pop ebx

    pop ebp
    ret