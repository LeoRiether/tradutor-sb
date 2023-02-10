section .text
global _start

;;;;;;;;;;;;;;;;;;;;;;;;
;        _start        ;
;;;;;;;;;;;;;;;;;;;;;;;;
_start:
    call calc_fibs

    mov ecx, 0 ; i
print_fibs.loop:
    cmp ecx, 16
    jge print_fibs.out

    ; Print the i-th fibonacci number
    push ecx
    mov eax, [fibs+ecx*4]
    call OUTPUT.int
    pop ecx

    inc ecx
    jmp print_fibs.loop
print_fibs.out:

    mov ecx, str2
    mov edx, str2_len
    call OUTPUT.str

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Calc fibs        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
calc_fibs:
    mov DWORD [fibs], 1
    mov DWORD [fibs+4], 1
    mov ecx, 2
calc_fibs.loop:
    cmp ecx, 16
    jge calc_fibs.exit
    
    mov eax, [fibs+ecx*4-4]
    add eax, [fibs+ecx*4-8]
    mov [fibs+ecx*4], eax
    inc ecx
    jmp calc_fibs.loop
calc_fibs.exit:
    ret

;;;;;;;;;;;;;;;;;;;;;;;
;        INPUT        ;
;;;;;;;;;;;;;;;;;;;;;;;
INPUT:
    
INPUT.exit:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.int        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; eax = integer to print
OUTPUT.int:
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

section .bss
    int.buffer resb 12 ; buffer for OUTPUT.int
    fibs resd 16

section .data

    str1 db "Hello World!", 10 
    str1_len equ $-str1

    str2 db "Hello Assembly!", 10
    str2_len equ $-str2

    str3 db "Hello there!", 10
    str3_len equ $-str3

