;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.str        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push {pointer to buffer}
; push {buffer length}
OUTPUT.str:
    pop eax ; return address
    pop edx ; buffer length
    pop ecx ; pointer to buffer
    push eax ; return address
    mov eax, 4 ; write to
    mov ebx, 1 ; stdout
    int 80h
    ret
