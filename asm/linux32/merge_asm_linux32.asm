%define h [ebp+8]
%define w [ebp+12]
%define frame1 [ebp+16]
%define frame2 [ebp+20]
%define frame_out [ebp+24]

section .text

global merge_frames_asm

; void merge_frames(int h,int w, unsigned char frame1[][w][3],unsigned char frame2[][w][3],unsigned char frame_out[][w][3])

merge_frames_asm:

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    ; get arguments
    ; [ebp+8] : h
    ; [ebp+12] : w
    ; [ebp+16] : frame1
    ; [ebp+20] : frame2
    ; [ebp+24] : frame_out

        xor edi, edi ; y = 0
    .Ly:
        cmp edi, h ; y < h
        jge .Lend ; end of the program if y >= h

        xor esi, esi ; x = 0
    .Lx:
        cmp esi, w ; x < w
        jge .Lnext_y ; y++ if x >= w

        ; calculate offsets for frame1[y][x][0], frame2[y][x][0], and frame_out[y][x][0]
        mov eax, edi ; move y to eax
        mul DWORD w ; multiply y with w
        add eax, esi ; add the x to result 
        mov ebx, 3 ; multiply the result with 3 (red, blue, green)
        mul ebx

        ; red pixel
        xor ebx, ebx ; in order to burn the gunk
        xor edx, edx ; in order to burn the gunk
        mov ecx, frame1
        mov bl, [ecx + 1 * eax] ; get the pixel from array1 to do operation with it
        mov ecx, frame2
        mov dl, [ecx + 1 * eax] ; get the pixel from array2 to do operation with it
        add bx, dx ; add pixel values together
        cmp bx, 255
        jg .Lred_max
    .Lred_add:
        mov ecx, frame_out
        mov BYTE [ecx + 1 * eax], bl ; put the output to the frame_out
        jmp .Lred_end
    .Lred_max:
        mov ecx, frame_out
        mov BYTE [ecx + 1 * eax], 255 ; put the output to the frame_out
    .Lred_end:
        
        ; green pixel
        ; calculate offsets for frame1[y][x][1], frame2[y][x][1], and frame_out[y][x][1]
        inc eax ; after red pixel here goes green pixel
        xor ebx, ebx ; in order to burn the gunk
        xor edx, edx ; in order to burn the gunk
        mov ecx, frame1
        mov dl, [ecx + 1 * eax] ; get the pixel from array1 to do operation with it
        mov ecx, frame2
        mov bl, [ecx + 1 * eax] ; get the pixel from array2 to do operation with it
        add bx, dx ; add pixel values together
        cmp bx, 255
        jg .Lgreen_max
    .Lgreen_add:
        mov ecx, frame_out
        mov BYTE [ecx + 1 * eax], bl ; put the output to the frame_out
        jmp .Lgreen_end
    .Lgreen_max:
        mov ecx, frame_out
        mov BYTE [ecx + 1 * eax], 255 ; put the output to the frame_out
    .Lgreen_end:

        ; blue pixel
        ; calculate offsets for frame1[y][x][2], frame2[y][x][2], and frame_out[y][x][2]
        inc eax ; after green pixel here goes blue pixel
        xor ebx, ebx ; in order to burn the gunk
        xor edx, edx ; in order to burn the gunk
        mov ecx, frame1
        mov bl, [ecx + 1 * eax] ; get the pixel from array1 to do operation with it
        mov ecx, frame2
        mov dl, [ecx + 1 * eax] ; get the pixel from array2 to do operation with it
        add bx, dx ; add pixels together
        cmp bx, 255
        jg .Lblue_max
    .Lblue_add:
        mov ecx, frame_out
        mov BYTE [ecx + 1 * eax], bl ; put the output to the frame_out
        jmp .Lblue_end
    .Lblue_max:
        mov ecx, frame_out
        mov BYTE [ecx + 1 * eax], 255 ; put the output to the frame_out
    .Lblue_end:
        
    .Lnext_x:
        inc esi ; increase x -> x++
        jmp .Lx


    .Lnext_y:
        inc edi ; increase y -> y++
        jmp .Ly

    .Lend:

    pop edi
    pop esi
    pop ebx

    pop ebp

	ret
