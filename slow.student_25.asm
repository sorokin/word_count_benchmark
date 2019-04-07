;r11 - flag for word, r12 - flag for white space, r10 - answer
SYS_OPEN equ 2
SYS_CLOSE equ 3
SYS_READ equ 0
SYS_WRITE equ 1

%macro exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

section .bss
	char resb 1
	digits resb 100
	digitsPos resb 8
	printOut resb 1
section .data
	;filename db "input.txt", 0
	;filename2 db "output.txt", 0

section .text
	global _start
_start:
	pop rax
	pop rax
	pop rdi
	pop rbp
	call _open
	mov r12, 1
_loop:
	call _getChar
	cmp rax, 0
	je finish

	mov r8, [char]

	cmp r8, 9
	jge _makeGreaterEquals
_continue:
	cmp r8, 13
	jle _makeLessEquals
_continue2:
	and r13, r14
	cmp r13, 1
	je _makeSpace
	cmp r8, 32
	je _makeSpace

	jmp _makeWord

_open:
	mov rax, SYS_OPEN
	mov rdi, rdi
	mov rsi, 0
	mov rdx, 0
	syscall
	mov r9, rax
	ret

_getChar:
	mov rax, char
	xor rax, rax
	mov [char], rax

	mov rdi, r9
	mov rax, SYS_READ
	mov rsi, char
	mov rdx, 1
	syscall
	ret

_makeWord:
	cmp r12, 1
	je _cntAnswer
	jmp _xorAll


_cntAnswer:
	inc r10
	jmp _xorAll

_xorAll:
	xor r12, r12
	xor r13, r13
	xor r14, r14
	jmp _loop

_makeSpace:
	mov r12, 1
	mov r11, 0
	xor r13, r13
	xor r14, r14
	jmp _loop

_makeGreaterEquals:
	mov r14, 1
	jmp _continue

_makeLessEquals:
	mov r13, 1
	jmp _continue2

finish:
	mov rcx, digits
	mov rbx, 10
	mov [rcx], rbx
	inc rcx
	mov [digitsPos], rcx
	mov rax, r10
	mov rbx, 10

_printRAXLoop:
	xor rdx, rdx
	div rbx
	push rax
	add rdx, 48

	mov rcx, [digitsPos]
	mov [rcx], dl
	inc rcx
	mov [digitsPos], rcx

	pop rax
	cmp rax, 0
	jne _printRAXLoop

	;mov rax, SYS_OPEN
	;mov rdi, rbp
	;mov rsi, 0x241
	;mov rdx, 0644o
	;syscall
	mov rcx, [digitsPos]
	dec rcx
	mov [digitsPos], rcx
	;mov r8, rax
	mov r8, 1
	
_printBackWords:
	mov rcx, [digitsPos]

	mov rdi, r8
	mov rax, SYS_WRITE
	mov rsi, rcx
	mov rdx, 1
	syscall

	mov rcx, [digitsPos]
	dec rcx
	mov [digitsPos], rcx

	cmp rcx, digits
	jge _printBackWords

	mov rax, SYS_CLOSE
	mov rdi, r8
	syscall

	mov rax, SYS_CLOSE
	mov rdi, r9
	syscall

	mov rax, 60
	mov rdi, 0
	syscall
