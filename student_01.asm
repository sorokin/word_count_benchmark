                section         .text

                global          _start

_start:
                pop             rax
                cmp             rax, 2
                jne             bad_args

                pop             rax
                pop             rdi
                mov             rax, 2
                xor             rsi, rsi
                xor             rdx, rdx
                syscall
                cmp             rax, 0
                jl              open_fail
                mov             rdi, rax

                xor             rbx, rbx
                xor             r8, r8

.read_again:
                xor             rax, rax
                mov             rsi, buf
                mov             rdx, buf_size
                syscall

                lea             rsi, [buf + rax]
                neg             rax
                jz              exit
                dec             rax
                jg              read_fail
                jmp             .next_byte
.cleanup:
                xor             r8, r8
.next_byte:
                inc             rax
                jz              .read_again
                cmp             r8, 0
                jne             .skip_not_whites
                movzx           edx, byte [rsi + rax]
.check:
                cmp             dl, 32
                je              .cleanup
                cmp             dl, 9
                je              .cleanup
                cmp             dl, 10
                je              .cleanup
                cmp             dl, 11
                je              .cleanup
                cmp             dl, 12
                je              .cleanup
                cmp             dl, 13
                je              .cleanup
                cmp             r8, 0
                jne             .skip_not_whites
.after_check:
                inc rbx
.skip_not_whites:
                inc             rax
                jz              .read_again
                mov             r8, 1;
                movzx           edx, byte [rsi + rax]
                jmp             .check
exit:
                mov             rax, 3
                syscall

                mov             rax, rbx
                call            write_number

                mov             rax, 60
                xor             rdi, rdi
                syscall

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

bad_args:
                mov             rsi, bad_args_msg
                mov             rdx, bad_args_msg_size
                jmp             print_error_and_quit

open_fail:
                mov             rsi, open_fail_msg
                mov             rdx, open_fail_msg_size
                jmp             print_error_and_quit

read_fail:
                mov             rsi, read_fail_msg
                mov             rdx, read_fail_msg_size
                jmp             print_error_and_quit

write_fail:
                mov             rsi, write_fail_msg
                mov             rdx, write_fail_msg_size
                jmp             print_error_and_quit

print_error_and_quit:
                mov             rax, 1
                mov             rdi, 1
                syscall

                mov             rax, 60
                mov             rdi, 1
                syscall

                section         .rodata
bad_args_msg:   db              "argument number mismatch", 10
bad_args_msg_size: equ $ - bad_args_msg
open_fail_msg:  db              "open failed", 10
open_fail_msg_size: equ $ - open_fail_msg
read_fail_msg:  db              "read failed", 10
read_fail_msg_size: equ $ - read_fail_msg
write_fail_msg: db              "write failed", 10
write_fail_msg_size: equ $ - write_fail_msg

                section         .bss

buf_size:       equ             16 * 1024
buf:            resb            buf_size
