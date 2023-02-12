#!/bin/bash

# Usage: `./gen-bin input.asm output`

NASM='yasm -p nasm'

$NASM -p nasm -f elf -o __tmp.o "$1"
ld -m elf_i386 -s -o "$2" __tmp.o
rm __tmp.o
