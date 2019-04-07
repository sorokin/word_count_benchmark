STEP equ 1
section .text
			   global          _start




print_number:
                mov             rbp, rsp		;remember rsp
                mov             rdi, rsp		;rdi - msg
                sub             rsp, 24

                dec             rdi
                mov             byte [rdi], 10	;add \n

                or              rax, rax
                jz              write_zero		;0

                mov             ebx, 10
loop:
                xor             edx, edx		;ax=00ax/bx
                div             rbx				;dx=00ax%bx

                add             edx, '0'
                dec             rdi
                mov             byte [rdi], dl	;\n...(cur)

                or              rax, rax
                jnz             loop
                jmp             print

write_zero:
                dec             rdi
                mov             byte [rdi], '0'

print:
                mov             rax, 1
                mov             rsi, rdi
                mov             rdx, rbp
                sub             rdx, rdi	;rdx = len
                mov             rdi, 1
                syscall			;rax - syswrite(1), rdi - in(0)/out(1), rsi - msg, rdx - length

                mov             rsp, rbp
                ret


_start:

				pop             rax
                cmp             rax, 2
                jne             badArgs
				
				
				pop             rax
                pop             rdi
                mov             rax, 2
                xor             rsi, rsi
                xor             rdx, rdx
                syscall			;rdi = name
                cmp             rax, 0
                jl              exit
                mov             rdi, rax

                xor             rbx, rbx


				xor r9, r9		;count
				mov r10, 0		;is on word now
again:
				xor rax, rax
				mov rsi, buf
				mov rdx, 1024
				syscall

				lea             rsi, [buf + rax]
                neg             rax
                jz              exit
                jg              readfail
				
				
do:
				movzx           edx, byte [rsi + rax]
				
				cmp             dl, 9
				je found_zero
				cmp             dl, 10
				je found_zero
				cmp             dl, 11
				je found_zero
				cmp             dl, 12
				je found_zero
				cmp             dl, 13
				je found_zero
				cmp             dl, 32
				je found_zero
				
				jmp found_one
				
found_one:
				cmp r10, 1
				je nextt
				inc r9
				mov r10, 1
				jmp nextt
				
found_zero:
				xor r10, r10
nextt:
				inc rax
				jnz do
				
				jmp again
				
				
				
readfail:		ud2
badArgs:
                mov             rsi, badmsg
                mov             rdx, badmsg_size
				mov             rax, 1
                mov             rdi, 1
                syscall

                mov             rax, 60
                mov             rdi, 1
                syscall
exit: 			


				mov             rax, 3
                syscall


                mov             rax, r9
                call            print_number

				mov rax, 60
				xor rdi, rdi
				syscall
				
section         .rodata
badmsg:   db              "Test.txt", 0x0a
badmsg_size: equ $ - badmsg

section         .bss
buf:			resb 1024
rbuf:			resb 1024
