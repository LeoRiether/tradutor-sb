;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        INPUT.str        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push {pointer to buffer}
; push {buffer length}
INPUT.str:
    mov eax, 3 ; sys_read
    mov ebx, 0 ; stdin
    mov ecx, [esp+8] ; pointer to buffer
    mov edx, [esp+4] ; buffer length
    int 80h
    push ecx
    push eax
    push read_bytes.msg
    push read_bytes.msg.len
    call OUTPUT.str
    call OUTPUT.int
    pop ecx
    ret 8
