section .text

global _start
_start:
		pop		rax
		cmp		rax, 2
		jne 		error_params

		pop		rax
		pop		rdi
		mov		rax, 2
		xor		rsi, rsi
		xor		rdx, rdx
		syscall 
		cmp		rax, 0
		jl		error_openfile

		xor		r15, r15
		mov r12, 9
		mov r14, rax;
	read_loop:
		xor 		rax, rax
		mov 		rdi, r14
		mov 		rsi, text_buffer
		mov 		rdx, text_size
		syscall
		cmp 		rax, 0
		jl 		_exit
		je 		read_loop_end

		xor 		r9, r9
		symbol:
			xor 		rcx, rcx
			mov 		cl, [text_buffer + r9]
			mov 		r13, rcx
			call 		is_word
			add 		r15, rcx
			inc 		r9
			mov 		r12, r13
			dec 		rax
		jnz 		symbol
	jmp 		read_loop
	read_loop_end:

		mov 		r13, array
		cmp 		r15, 0
		je 		sout_zero

		mov 		r10, 10
		mov 		rax, r15
	div_cycle:
			xor 		dx, dx
			div 		r10
			add 		dx, '0'
			mov 		[r13], dx
			inc 		r13
			cmp 		ax, 0
			jne 		div_cycle

	sout_cycle:
			dec 		r13
			call 		sout_symbol
			cmp 		r13, array
			jne 		sout_cycle

			jmp 		_exit



sout_symbol:
		mov 		rax, 1
		mov 		rdi, 1
		mov 		rsi, r13
		mov 		rdx, 1
		syscall
		ret

is_word:
		cmp 		r12, 9
		jl 		_ret_bad
		cmp 		r12, 13
		jle 		_check_r13
		cmp 		r12, 32
		jne 		_ret_bad
	_check_r13:
		cmp 		r13, 9
		jl 		_ret_good
		cmp 		r13, 13
		jle 		_ret_bad
		cmp 		r13, 32
		jne 		_ret_good
		je 		_ret_bad
	_ret_bad:
			xor 		rcx, rcx
			ret
	_ret_good:
			xor 		rcx, rcx 
			inc 		rcx
			ret

_exit:
		mov 		r13, array
		mov 		[r13], byte 0x0a
		call 		sout_symbol

		mov 		rax, 3
		mov 		rdi, r14
		syscall

		mov 		rax, 60
		xor 		rdi, rdi
		syscall
error_params:
		mov             rax, 1
		mov             rdi, 1
                mov             rsi, params
                mov             rdx, 26
                syscall
		call 		_exit

error_openfile:
		mov             rax, 1
		mov             rdi, 1
                mov             rsi, fileop
                mov             rdx, 12
                syscall
		call 		_exit

sout_zero:
		mov [r13], byte '0'
		call sout_symbol
		jmp _exit

section         .rodata
params:           db              "Wrong number of arguments!"
fileop:           db              "Open failed!"

section 	.data
array 		times 20 db 0
text_size 	equ 1024

section 	.bss
text_buffer resb 1024
