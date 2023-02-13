SECTION TEXT
    OUTPUT_S HW, 13

    INPUT BEFORE_X+1

    OUTPUT_S MESSAGE, 32

    LOAD X

MYLOOP:
    ; REM BASE
    DIV BASE
    MUL BASE
    STORE AUX
    LOAD X
    SUB AUX

    SUB NINE ; rem > 9
    JMPP AF
    ; [0..9]
    ADD NINE
    ADD ZEROASCII
    STORE CHR
    OUTPUT_C CHR
    JMP LOOPCONTINUE

AF:
    ; [A..F]
    ADD NINE
    SUB TEN
    ADD AASCII
    STORE CHR
    OUTPUT_C CHR

LOOPCONTINUE:
    LOAD X
    DIV BASE
    STORE X
    JMPP MYLOOP

MYOUT:
    OUTPUT_C HW+3 ; newline
    STOP

TESTSECTION:
    INPUT_S BASE, 10
    OUTPUT_S HW, 13
    INPUT_C AUX+0xA
    OUTPUT_C CHR+2

SECTION DATA
    BASE: CONST 16
    NINE: CONST 9
    TEN: CONST 10
    AASCII: CONST 65
    ZEROASCII: CONST 48
    BEFORE_X: SPACE
    X: SPACE
    CHR: SPACE
    AUX: SPACE

    HW:
    CONST 'H'
    CONST 'e'
    CONST 'l'
    CONST 'l'
    CONST 'o'
    CONST ' '
    CONST 'w'
    CONST 'o'
    CONST 'r'
    CONST 'l'
    CONST 'd'
    CONST '!'
    CONST 10

    MESSAGE:
    CONST 'R'
    CONST 'e'
    CONST 'p'
    CONST 'r'
    CONST 'e'
    CONST 's'
    CONST 'e'
    CONST 'n'
    CONST 't'
    CONST 'a'
    CONST 'c'
    CONST 'a'
    CONST 'o'
    CONST ' '
    CONST 'e'
    CONST 'm'
    CONST ' '
    CONST 'h'
    CONST 'e'
    CONST 'x'
    CONST ' '
    CONST 'i'
    CONST 'n'
    CONST 'v'
    CONST 'e'
    CONST 'r'
    CONST 't'
    CONST 'i'
    CONST 'd'
    CONST 'a'
    CONST ':'
    CONST ' '

