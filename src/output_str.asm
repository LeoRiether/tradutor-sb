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
