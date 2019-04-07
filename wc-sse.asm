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
                xor             ebp, ebp
                pxor            xmm4, xmm4
                movdqa          xmm5, oword [nines]
                movdqa          xmm6, oword [fours]
                movdqa          xmm7, oword [thirty_twos]

.read_again:
                xor             rax, rax
                mov             rsi, buf
                mov             rdx, buf_size
                syscall

                cmp             rax, 0
                jz              exit
                jl              read_fail

                mov             r8, rax
                shr             r8, 4
                or              r8, r8
                jz             .skip_by_16b_chunk

                xor             ebp, 1
.next_16b_chunk:
                movdqa          xmm0, oword [rsi]
                movdqa          xmm1, xmm0
                psubb           xmm0, xmm5
                pcmpeqb         xmm1, xmm7
                psubusb         xmm0, xmm6
                pcmpeqb         xmm0, xmm4
                por             xmm0, xmm1
                pmovmskb        ecx, xmm0
                mov             edx, ecx            ; FF80
                shl             ecx, 1              ; 1FF00
                or              ecx, ebp            ; 1FF00
                mov             ebp, edx
                shr             ebp, 15
                xor             edx, 0xffff         ; 007F
                and             ecx, edx            
                popcnt          ecx, ecx
                add             rbx, rcx
                
                add             rsi, 16
                dec             r8
                jnz             .next_16b_chunk

                xor             ebp, 1

                and             rax, 0x0f
                jz              .read_again
                
.skip_by_16b_chunk:

.next_byte:
                movzx           edx, byte [rsi]
                lea             ecx, [rdx - 9]
                cmp             cl, 4
                seta            cl
                cmp             dl, 32
                setne           dl
                xor             ebp, 1
                and             ecx, edx
                and             ebp, ecx
                add             rbx, rbp
                mov             ebp, ecx
                inc             rsi
                dec             rax
                jnz             .next_byte

                jmp             .read_again

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

                align           16
nines:
                times 16 db     9
fours:
                times 16 db     4
thirty_twos:
                times 16 db     32

                section         .bss

buf_size:       equ             16 * 1024
buf:            resb            buf_size
