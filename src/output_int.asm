;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.int        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push {integer to print}
OUTPUT.int:
    mov eax, [esp+4] ; integer to print
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
