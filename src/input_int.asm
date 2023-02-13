;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        INPUT.int        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns eax with the integer
INPUT.int:
    mov eax, 3 ; sys_read
    mov ebx, 0 ; stdin
    mov ecx, int.buffer
    mov edx, 12
    int 80h

    mov eax, 0 ; integer value
    mov ecx, 0 ; buffer index

    jmp INPUT.convert_ascii.int
    
INPUT.convert_ascii_loop.int:
    inc ecx

INPUT.convert_ascii.int:
    cmp BYTE [int.buffer + ecx], '-' ; ignore '-'
    je INPUT.convert_ascii_loop.int

    cmp BYTE [int.buffer + ecx], '0' ; char < '0' non-numerical
    jb INPUT.check_sign.int

    cmp BYTE [int.buffer + ecx], '9' ; char > '9' non-numerical
    ja INPUT.check_sign.int

    ; ans *= 10
    mov ebx, 10
    imul ebx

    ; ans += char - '0'
    movzx ebx, BYTE [int.buffer + ecx]
    add eax, ebx
    sub eax, '0'

    jmp INPUT.convert_ascii_loop.int

INPUT.check_sign.int:
    ; if positive, skip to the end
    cmp BYTE [int.buffer], '-'
    jne INPUT.int.exit

INPUT.negative.int:
    mov ebx, -1
    imul ebx
    
INPUT.int.exit:
    ret
