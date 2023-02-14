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
    mov eax, [fibs+ecx*4]
    push eax
    call OUTPUT.int
    add esp, 4
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
    push str_in
    push str_in_len
    call OUTPUT.str
    add esp, 8
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

%include "input_str.asm"
%include "input_int.asm"
%include "output_str.asm"
%include "output_int.asm"

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

