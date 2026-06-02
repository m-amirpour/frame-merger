bits 32

global _merge_frames_asm

section .text

_merge_frames_asm:

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    ; args
    %define h         [ebp+8]
    %define w         [ebp+12]
    %define frame1    [ebp+16]
    %define frame2    [ebp+20]
    %define frame_out [ebp+24]

    xor edi, edi

.y_loop:
    mov eax, edi
    cmp eax, h
    jge .done

    xor esi, esi

.x_loop:
    mov eax, esi
    cmp eax, w
    jge .next_row

    mov eax, edi
    imul eax, dword w
    add eax, esi
    lea eax, [eax + eax*2]

    ; R
    mov ebx, frame1
    movzx ecx, byte [ebx + eax]
    mov ebx, frame2
    movzx edx, byte [ebx + eax]
    add ecx, edx
    cmp ecx, 255
    jbe .r_ok
    mov ecx, 255
.r_ok:
    mov ebx, frame_out
    mov [ebx + eax], cl

    ; G
    mov ebx, frame1
    movzx ecx, byte [ebx + eax + 1]
    mov ebx, frame2
    movzx edx, byte [ebx + eax + 1]
    add ecx, edx
    cmp ecx, 255
    jbe .g_ok
    mov ecx, 255
.g_ok:
    mov ebx, frame_out
    mov [ebx + eax + 1], cl

    ; B
    mov ebx, frame1
    movzx ecx, byte [ebx + eax + 2]
    mov ebx, frame2
    movzx edx, byte [ebx + eax + 2]
    add ecx, edx
    cmp ecx, 255
    jbe .b_ok
    mov ecx, 255
.b_ok:
    mov ebx, frame_out
    mov [ebx + eax + 2], cl

    inc esi
    jmp .x_loop

.next_row:
    inc edi
    jmp .y_loop

.done:

    pop edi
    pop esi
    pop ebx
    pop ebp
    ret