SIZE equ 8192
BYTESTEP equ 1
NEUTRAL equ 65
A equ 65
Z equ 90
A_small equ 97
Z_small equ 122

				section         .text
				global          _start

_start:
		xor 	r10, r10		; answer
		
		pop 	rax
		cmp 	rax, 2
		jne 	exit
		
		pop 	rax
		
		pop		rdi
		
		mov 	rax, 2
		xor 	rsi, rsi
		xor		rdx, rdx
		
		syscall
		
		cmp 	rax, 0
		jl 		open_fail
		
		mov 	r13, rax
		mov 	cl, NEUTRAL
		
		; cl - previous symbol
again:
		xor 	rcx, rcx
		
		mov 	rax, r13
		
		mov 	rdi, rax 		; rdi = rax
		xor 	rax, rax 		; rax = 0
		mov 	rsi, buf 		; set a pointer
		mov 	rdx, SIZE 		; attempt to read 1024 bytes
		syscall
		
		cmp 	rax, 0			; if read less then 0 - error
		je 		print_answer	;
		jl 		read_fail		;
		
		mov 	r12, rax
		
		xor 	r11, r11
		mov		r11, buf
		add		r11, rax
		dec 	r11	
loop:
		cmp 	rax, -1
		je 		loop_finish
		
		mov 	bl, cl
		mov 	cl, byte[r11]
		call 	is_letter
		cmp 	r15, 1
		jne 	continue
		
		xor 	bl, bl
		mov 	bl, byte[r11] 
		call 	is_letter		; is_letter(bl), answer in r15
		cmp 	r15, 0
		jne		continue
		
plus_word:
		inc 	r10
		
continue:
		dec 	rax
		dec 	r11
		jmp 	loop
		
loop_finish:
		;mov		cl, dl
		cmp 	r12, 0
		jne 	again
		
print_answer:
		mov 	rax, r10
		call 	print_integer
		jmp 	exit
		
;;; CHECKING BL FOR NON_WHITESPACE ;;;
		is_letter:					; bl - arg, r15 - ans
				cmp 	bl, 9
				je 		return_false

				cmp 	bl, 10
				je 		return_false

				cmp 	bl, 11
				je 		return_false

				cmp 	bl, 12
				je 		return_false

				cmp 	bl, 13
				je 		return_false

				cmp 	bl, 32
				je 		return_false

		return_true:
				mov 	r15, 1
				ret

		return_false:
				mov 	r15, 0
				ret
		
;;; PRINTING INTEGER FROM RAX REGISTER ;;;
		print_integer:
				xor		dx, dx				; num
				mov 	bx, 10				; divider
				mov 	r10, buf			; address in buf
				mov 	r11, 0				; pos in buf

		divide_loop:
				div 	bx					; put to dx mod from div of my num to r9
				mov 	word [r10], dx		; digit to buffer
				add		word [r10], 48		; add zero letter value
				xor 	dx, dx				; 
				add 	r10, BYTESTEP		; increase address 
				add 	r11, 1				; increase the size

				cmp 	ax, 0				; if nothing remains
				je 		reverse				; go to reverse

				jmp 	divide_loop			; else repeat division

		reverse:
				mov 	r12, rbuf			; r12 - address
				xor 	r13, r13			; r13 - pos in buffer
				sub 	r10, BYTESTEP		; now r10 points to last piece of actual info

		reverse_loop:
				cmp		r11, 0				; if copied everything
				je 		printing_part		; let's print it

				mov 	r14, [r10]			; otherwise copy from r10 to r14
				mov 	[r12], r14			; and finally to r12

				sub 	r10, BYTESTEP		; keeping actual address of buf 
				sub		r11, 1 				; and size
				add 	r12, BYTESTEP		; keeping actual address of rbuf
				add		r13, 1				; and size

				jmp 	reverse_loop		;


		printing_part:
				mov 	rax, r13
				mov 	r13, BYTESTEP
				mul		r13
				mov		rdx, rax			; set up, how much to write
				mov 	rax, 1				; set up to call writing
				mov 	rdi, 1				; set up some unknown stuff
				mov 	rsi, rbuf			; set up data address
				syscall

				ret
		
open_fail:
read_fail:
		jmp exit
		
exit:
		mov 	rax, 60
		xor 	rdi, rdi
		syscall
	
		
				section 		.bss
				
buf: 			resb 			SIZE
rbuf: 			resb			SIZE
