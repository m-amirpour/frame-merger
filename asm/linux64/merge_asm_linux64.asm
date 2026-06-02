global merge_frames_asm

section .text

merge_frames_asm:

    ; Linux SysV ABI:
    ; rdi = h
    ; rsi = w
    ; rdx = frame1
    ; rcx = frame2
    ; r8  = frame_out

    mov r10, r8          ; frame_out
    mov r8,  rdx         ; frame1
    mov r9,  rcx         ; frame2

    mov eax, edi
    imul eax, esi
    imul eax, 3          ; total bytes

    mov r11d, eax        ; save byte count

    mov ecx, eax
    shr ecx, 4           ; number of 16-byte chunks

    test ecx, ecx
    jz .tail

.loop:
    movdqu xmm0, [r8]
    movdqu xmm1, [r9]

    paddusb xmm0, xmm1

    movdqu [r10], xmm0

    add r8, 16
    add r9, 16
    add r10, 16

    dec ecx
    jnz .loop

.tail:
    and r11d, 15
    jz .done

.tail_loop:
    mov al, [r8]
    add al, [r9]
    jc .cap

    jmp .store

.cap:
    mov al, 255

.store:
    mov [r10], al

    inc r8
    inc r9
    inc r10

    dec r11d
    jnz .tail_loop

.done:
    ret