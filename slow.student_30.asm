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

		xor		rbx, rbx

		mov             r15, 0
		mov		r14, 0

; r14 - is last not-wp
again:
		call            read_char

		cmp		byte [buf], 9
		je		white_space
		cmp		byte [buf], 10
		je		white_space
		cmp		byte [buf], 11
		je		white_space
		cmp		byte [buf], 12
		je		white_space
		cmp		byte [buf], 13
		je		white_space
		cmp		byte [buf], 32
		je		white_space
		mov		r14, 1
		jmp		again

white_space:
		add		r15, r14
		mov		r14, 0
		jmp		again

read_char:
		mov		rax, 0
		mov             rsi, buf
		mov             rdx, 1
		syscall
		cmp             rax, 0
		jl              read_fail
		je              exit
		ret

exit:
		mov             rax, 3
		syscall

		add		r15, r14
		mov             rax, r15
		call            write_number

		mov             rax, 60
		xor             rdi, rdi
		syscall

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

print_error_and_quit:
		mov             rax, 1
		mov             rdi, 1
		syscall

		mov             rax, 60
		mov             rdi, 1
		syscall

read_fail:
write_fail:
		ud2

		section		.rodata
bad_args_msg:   db              "argument number mismatch", 10
bad_args_msg_size: equ $ - bad_args_msg
open_fail_msg:  db              "open failed", 10
open_fail_msg_size: equ $ - open_fail_msg
read_fail_msg:  db              "read failed", 10
read_fail_msg_size: equ $ - read_fail_msg
write_fail_msg: db              "write failed", 10
write_fail_msg_size: equ $ - write_fail_msg

		section         .bss
buf:            resb            1
