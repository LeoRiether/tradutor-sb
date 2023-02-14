;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        INPUT.str        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push {pointer to buffer}
; push {buffer length}
INPUT.str:
    pop eax ; return address
    pop edx ; buffer length
    pop ecx ; pointer to buffer
    push eax ; return address
    mov eax, 3 ; sys_read
    mov ebx, 0 ; stdin
    int 80h
    ret
