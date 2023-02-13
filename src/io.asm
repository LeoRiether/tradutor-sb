section .bss
    int.buffer resb 12 ; buffer for INPUT/OUTPUT.int

    fibs resd 50

section .data
    OUTPUT.msg db "Quantidade de bytes escritos = " ; message for OUTPUT
    OUTPUT.msg.len equ $ - OUTPUT.msg

    str_in db "How many fibonacci numbers?", 10
    str_in_len equ $-str_in

    fibs_n dw 0, 8

section .text
global _start

;;;;;;;;;;;;;;;;;;;;;;;;
;        _start        ;
;;;;;;;;;;;;;;;;;;;;;;;;
_start:
    call calc_fibs

    mov ecx, 0 ; i
print_fibs.loop:
    cmp ecx, [fibs_n]
    jge exit

    ; Print the i-th fibonacci number
    push ecx
    mov eax, [fibs+ecx*4] ; parameter
    push eax
    call OUTPUT.int
    pop ecx

    inc ecx
    jmp print_fibs.loop

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Calc fibs        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
calc_fibs:
    ; input n
    mov ecx, str_in
    mov edx, str_in_len
    call OUTPUT.str
    call INPUT.int
    mov [fibs_n], eax

    mov DWORD [fibs], 0
    mov DWORD [fibs+4], 1
    mov ecx, 2
calc_fibs.loop:
    cmp ecx, DWORD [fibs_n]
    jge calc_fibs.exit
    
    mov eax, [fibs+ecx*4-4]
    add eax, [fibs+ecx*4-8]
    mov [fibs+ecx*4], eax
    inc ecx
    jmp calc_fibs.loop
calc_fibs.exit:
    ret

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        INPUT.str        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Non-conventional calling:
; ecx = pointer to buffer
; edx = buffer length
INPUT.str:
    mov eax, 3 ; sys_read
    mov ebx, 0 ; stdin
    int 80h
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.int        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push {integer to print}
OUTPUT.int:
    pop ebx ; return address
    pop eax ; integer to print
    push ebx
    mov ecx, 0 ; buffer index

    cmp eax, 0
    jg OUTPUT.int.calc_length
    je OUTPUT.int.is_zero
    
    ; negative integer
    neg eax 
    mov BYTE [int.buffer + ecx], '-'
    inc ecx

; After calc_length, ecx will point to the index in int.buffer that shall
; contain the least significant digit of eax
OUTPUT.int.calc_length:
    push eax ; save eax
OUTPUT.int.calc_length.loop:
    cmp eax, 10
    jl OUTPUT.int.write_to_buffer ; eax is only a digit now, ecx is ready
    mov ebx, 10
    cdq ; !!!
    idiv ebx ; TODO: ver como o gcc divide por 10 com -O2
    inc ecx
    jmp OUTPUT.int.calc_length.loop

OUTPUT.int.write_to_buffer:
    pop eax
    push ecx ; save ecx for later
OUTPUT.int.write_to_buffer.loop:
    cmp eax, 0
    jle OUTPUT.int.buffer_to_stdout

    mov ebx, 10
    cdq ; !!!
    idiv ebx ; eax = quotient, edx = remainder
    add edx, '0'
    mov BYTE [int.buffer + ecx], dl

    dec ecx
    jmp OUTPUT.int.write_to_buffer.loop

OUTPUT.int.is_zero:
    push ecx
    mov BYTE [int.buffer + ecx], '0'

OUTPUT.int.buffer_to_stdout:
    pop edx ; from `push ecx`
    mov BYTE [int.buffer + edx + 1], 10 ; newline
    add edx, 2           ; edx = edx + 1 + newline
    mov eax, 4           ; "write to file" syscall
    mov ebx, 1           ; stdout
    mov ecx, int.buffer  ; buffer pointer
    int 80h              ; make the syscall
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.str        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Non-conventional calling:
; ecx = pointer to buffer
; edx = buffer length
OUTPUT.str:
    mov eax, 4 ; write to
    mov ebx, 1 ; stdout
    int 80h
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.ztstr        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; prints 0-terminated strings
; eax = pointer to buffer
OUTPUT.ztstr:
    mov ecx, eax ; pointer to current char
    mov ebx, 1   ; stdout (file descriptor == 1)
    mov edx, 1   ; buffer length (1 char)
OUTPUT.ztstr.loop:
    cmp BYTE [ecx], 0
    je OUTPUT.ztstr.exit  ; exit the loop on \0
    mov eax, 4            ; write syscall
    int 80h
    inc ecx
    jmp OUTPUT.ztstr.loop
OUTPUT.ztstr.exit:
    ret

