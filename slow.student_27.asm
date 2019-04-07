section .text
global _start

section .data
digit: dw ""

   ;r11 -- char
   print_char:
       push r11
       mov [rsp], r11
       mov rax, 1
       mov rdi, 1
       mov rsi, rsp
       mov rdx, 1
       syscall
       pop r11
       ret

   print_number:
       cmp rax, 0
       jge parse
           mov r11, 45
           mov rbp, rax
           call print_char
           mov rax, rbp
           neg rax
       parse:
       push -1
       loop1:
         xor rdx, rdx
         mov rcx, 10
         div rcx
         mov rbx, rdx
         push rbx
         cmp rax, 0
         jne loop1
       loop2:
         pop rbx
         cmp rbx, -1
         je end
             add rbx, 48
             mov r11, rbx
             call print_char
         jmp loop2
       end:
       mov r11, 10
       call print_char
       ret

   _sys_exit:
       mov rax, 1
       xor rbx, rbx
       syscall
       ret

_start:
    pop rax
    cmp rax, 2
    jne _sys_exit
    pop rax
    pop rdi
    mov rax, 2
    xor rsi, rsi
    xor rdx, rdx
    syscall
    cmp rax, 0
    jl _sys_exit
    mov r8, rax


; r9 == 1 if last character was not space
; rbx == answer
    xor rbx, rbx
 xor r9, r9
    read:
        mov rdi, r8
        xor rax, rax
        mov rsi, file
        mov rdx, 1
        syscall
        cmp rax, 0
        je end_program    

       cmp [file], byte 9
       jl not_space
       cmp [file], byte 32
       je inc_ans
       cmp [file], byte 13
       jg not_space
       inc_ans:
           cmp r9, 0
           je read
           add rbx, 1
           xor r9, r9
           jmp read
       not_space:
           mov r9, 1
           jmp read

    end_program:
 cmp r9, 1
 jne skip_add

 add rbx, 1
 skip_add:

    mov rax, rbx
    call print_number

    mov rax, 60     ; sys_exit
    xor rdi, rdi
    syscall

section .bss
file: resb 1
