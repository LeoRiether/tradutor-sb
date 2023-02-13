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
