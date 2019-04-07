section .text
global _start

print_number:
    push rax
    push rdi

    mov rdi, rsp

    dec rdi
    mov byte[rdi], 10

    mov rbx, 10
.wl:
    xor rdx, rdx
    div rbx
    add rdx, '0'
    dec rdi
    mov byte[rdi], dl
    cmp rax, 0
    jne .wl
.print:
    mov rsi, rdi
    mov rdx, rsp
    sub rdx, rdi
    mov rdi, 1
    mov rax, 1
    syscall

    pop rdi
    pop rax
    ret

calc_words:
    xor rbx, rbx
    mov r8, 1
.read:
    xor rax, rax
    mov rsi, buf
    mov rdx, buf.len
    syscall

    lea rsi, [buf + rax]
    neg rax
    jz .r
    jg read_fail
.wl:
    call skip_spaces

    cmp rax, 0
    je .read

    cmp r8, 0
    setne r8b
    add rbx, r8

    call skip_nspaces

    cmp rax, 0
    je .halved
    jmp .wl
.r:
    ret

.halved:
    xor r8, r8
    jmp .read

skip_spaces:
.wl:
    movzx edx, byte[rsi + rax]
    cmp dl, 32
    je .isspace
    cmp dl, 9
    jl .r
    cmp dl, 13
    jg .r
.isspace:
    inc rax
    mov r8, 1
    jnz .wl
    ret
.r:
    ret

skip_nspaces:
.wl:
    movzx edx, byte[rsi + rax]
    cmp dl, 9
    jl .isnspace
    cmp dl, 14
    jl .r
    cmp dl, 32
    je .r
.isnspace:
    inc rax
    jnz .wl
    ret
.r:
    ret

_start:
    pop rax
    cmp rax, 2
    jne bad_args

    pop rax
    pop rdi
    mov rax, 2
    xor rsi, rsi
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl open_fail
    mov rdi, rax
    call calc_words

exit:
    mov rax, 3
    syscall

    mov rax, rbx
    call print_number

    mov rax, 60
    mov rdi, 0
    syscall

error_exit:
    mov rax, 3
    syscall

    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

bad_args:
    mov rsi, bad_args_msg
    mov rdx, bad_args_msg.len
    jmp error_exit

open_fail:
    mov rsi, open_fail_msg
    mov rdx, open_fail_msg.len
    jmp error_exit

read_fail:
    mov rsi, read_fail_msg
    mov rdx, read_fail_msg.len
    jmp error_exit

section .rodata

bad_args_msg db 'bad arguments passed',10
.len equ $ - bad_args_msg

open_fail_msg db 'failed to open input file',10
.len equ $ - open_fail_msg

read_fail_msg db 'failed to read file',10
.len equ $ - read_fail_msg

section .bss

buf resb 1024
.len equ 1024
