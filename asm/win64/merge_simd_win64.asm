global merge_frames_simd
section .text

; rcx = h
; rdx = w
; r8  = frame1
; r9  = frame2
; [rsp+40] = frame_out

merge_frames_simd:
    mov r10, [rsp+40]   ; output pointer

    ; total_bytes = h * w * 3
    mov eax, ecx
    imul eax, edx
    imul eax, 3
    mov ecx, eax        ; loop counter in bytes

    xor r11, r11        ; offset = 0

.loop:
    cmp r11, rcx
    jae .done

    ; load 16 bytes safely
    movdqu xmm0, [r8 + r11]
    movdqu xmm1, [r9 + r11]

    paddusb xmm0, xmm1
    movdqu [r10 + r11], xmm0

    add r11, 16
    jmp .loop

.done:
    ret
