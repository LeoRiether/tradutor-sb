;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        OUTPUT.str        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push {pointer to buffer}
; push {buffer length}
OUTPUT.str:
    mov eax, 4 ; write to
    mov ebx, 1 ; stdout
    mov ecx, [esp+8]
    mov edx, [esp+4]
    int 80h
    ret
