section .data

fname db "1",

len equ 4

section .bss

buffer: resb 4

section .text

global _start

_start:
    ; open
    pop         rax
    pop         rax
    pop         rax
    mov         [fname], rax
    mov         rdi, [fname]; name of the file
    mov         rax, 2
    xor         rdx,rdx
    syscall

    mov         r12,rax
    xor         r15,r15
    .loop:
    call        readFile
    call        compare
    jmp         .loop
    call        exit

readFile:
mov         rdi, r12
xor         rax, rax
mov         rsi, buffer
mov         rdx, len
syscall
cmp         rax,0
jle         exit
ret
compare:
xor         rax,rax
mov         rcx, -1
.loop:
    inc             rcx
    xor             ah,ah
    cmp             rcx,len
    je              .return
    cmp             [buffer+rcx],ah
    je              .exitl
    jl              .exitl
    mov             r8, 9
    cmp             [buffer+rcx],r8b
    je              .addto
    mov             r8, 10
    cmp             [buffer+rcx],r8b
    je              .addto
    mov             r8, 11
    cmp             [buffer+rcx],r8b
    je              .addto
    mov             r8, 12
    cmp             [buffer+rcx],r8b
    je              .addto
    mov             r8, 13
    cmp             [buffer+rcx],r8b
    je              .addto
    mov             r8, 32
    cmp             [buffer+rcx],r8b
    je              .addto
    jmp             .loop
.skipSpaces:
    inc             rcx
    cmp             rcx,len
    je              .tryRead
    cmp             [buffer+rcx],ah
    je              exit
    jl              exit
    mov             r8, 9
    cmp             [buffer+rcx],r8b
    je              .skipSpaces
    mov             r8b, 10
    cmp             [buffer+rcx], r8b
    je              .skipSpaces
    mov             r8, 11
    cmp             [buffer+rcx],r8b
    je              .skipSpaces
    mov             r8, 12
    cmp             [buffer+rcx],r8b
    je              .skipSpaces
    mov             r8, 13
    cmp             [buffer+rcx],r8b
    je              .skipSpaces
    mov             r8, 32
    cmp             [buffer+rcx],r8b
    jne             .loop
    jmp             .skipSpaces
ret
.addto:
inc             r15
jmp             .skipSpaces
ret
.exitl:
inc             r15
jmp             exit
ret
.return:
ret
.tryRead:
call            readFile
mov             rcx,-1
jmp             .skipSpaces
ret
closeFile:
mov         rdi,r12
mov             rax, 3
syscall
ret
exit:
lea             rax, [r15]
call            write_number
call            closeFile
mov             rax, 60
xor             rdi, rdi
syscall
ret
; rax -- number to print
write_number:
                mov             rbp, rsp
                mov             rdi, rsp
                sub             rsp, 24

                dec             rdi
                mov             byte [rdi], 10

                or              rax, rax
                jz              .write_zero

                mov             ebx, 10
.loop:
                xor             edx, edx
                div             rbx

                add             edx, '0'
                dec             rdi
                mov             byte [rdi], dl

                or              rax, rax
                jnz             .loop
                jmp             .print

.write_zero:
                dec             rdi
                mov             byte [rdi], '0'

.print:
                mov             eax, 1
                mov             rsi, rdi
                mov             rdx, rbp
                sub             rdx, rdi
                mov             edi, eax
                syscall

                mov             rsp, rbp
                ret
