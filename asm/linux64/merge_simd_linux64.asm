global merge_frames_simd
section .text

merge_frames_simd:

    ; Linux SysV ABI:
    ; rdi = h
    ; rsi = w
    ; rdx = frame1
    ; rcx = frame2
    ; r8  = frame_out

    xor r11d, r11d      ; y = 0

.y_loop:
    cmp r11d, edi
    jge .done

    xor r12d, r12d      ; x = 0

.x_loop:
    cmp r12d, esi
    jge .next_row

    ; offset = (y*w + x)*3

    mov eax, r11d
    imul eax, esi
    add eax, r12d
    imul eax, 3

    mov r13, rax

    movdqu xmm0, [rdx + r13]
    movdqu xmm1, [rcx + r13]

    paddusb xmm0, xmm1

    movdqu [r8 + r13], xmm0

    add r12d, 4
    jmp .x_loop

.next_row:
    inc r11d
    jmp .y_loop

.done:
    ret