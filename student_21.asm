;	r8 -- answer
section			.text

				global 			_start
_start:
				pop rax
				cmp rax, 2
				jne error
				pop rax
				pop rdi
				mov rax, 2
				mov rsi, 0
				mov rdx, 0
				syscall
				cmp rax, 0
				jl error
				mov r10, rax
				mov				bl, 32
.loop:
				xor 			rax, rax
				mov	 			rdi, r10
				mov 			rsi, buff
				mov				rdx, 1024
				syscall
				cmp				rax, 0
				je 				.end
				
				xor				rcx, rcx
				mov				rsi, buff
.loop1:
				call			is_whitespace
				mov				r9, rdx
				mov				bl, [rsi]
				call			is_whitespace
				cmp				r9, 1
				je				.cond2
.back:
				dec				rax
				inc				rsi
				cmp				rax, 0
				jne				.loop1	

				jmp				.loop
.end:
				mov				rax, r8
				call 			write_number
				call 			exit
.cond2:
				cmp				rdx, 0
				je				.inc_ans
				jmp				.back
.inc_ans:
				inc				r8
				jmp				.back

; if bl is whitespace symbol rdx will be 1 else 0			
is_whitespace:
				xor				rdx, rdx
				cmp				bl, 32
				je				.set_rdx
				cmp				bl, 8
				jg				.cond2
.back:
				ret				
.cond2:
				cmp				bl, 14
				jl				.set_rdx
				jmp				.back
.set_rdx:
				inc 			rdx
				jmp				.back

; write 64-bit number from rax	
write_number:
				push 			rax
				push 			rdx
				push			rbx
				push 			r9
				
				xor				r9, r9
				mov				rbx, 10
.loop:			
				xor 			rdx, rdx
				div 			rbx
				push 			rdx
				inc 			r9
				cmp				rax, 0
				jne				.loop
.loop1:
				pop				rax
				add 			rax, '0'
				call			write_char
				dec 			r9
				jnz				.loop1
				
				mov				al, 0x0a
				call 			write_char
				
				pop				r9
				pop				rbx
				pop				rdx
				pop				rax
				ret
				
write_char:
				push			rax
				push			rdi
				push			rsi
				push			rdx
				
                sub             rsp, 1
                mov             [rsp], al
				mov             rax, 1
                mov             rdi, 1
                mov             rsi, rsp
                mov             rdx, 1
                syscall
                add             rsp, 1
                
                pop				rdx
                pop				rsi
                pop				rdi
                pop				rax
                ret
                
error:
				mov				rax, 60
				mov				rdi, 1
				syscall
exit:
                mov             rax, 60
                xor             rdi, rdi
                syscall
                
				section 		.bss
buff: 			resb			1024
