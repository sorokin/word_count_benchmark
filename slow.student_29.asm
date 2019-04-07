section .text

global _start

division:
  xor rdx, rdx
  div rcx
  add rax, 48
  mov [msg+ebp], rax
  add ebp, 1
  mov rax,rdx
  push rax
  xor rdx, rdx
  mov rsi, 10
  mov rax, rcx
  div rsi
  mov rcx, rax
  pop rax
  cmp rax, 0
  jne division
  ret


length:
 xor rdx, rdx
 add rbx, 1
 mov rsi, 10
 div rsi
 cmp rax, 0
 jne length
 ret

power:
 cmp rbx, 0
 je ends
 xor rdx, rdx
 mul rsi
 sub rbx, 1
 jmp power
 ends:
 ret

printNumberFromRax:
  mov rcx, 1
  mov ebp, 0
  xor bx, bx
  cmp rax, 0
  jge not_negate
    mov rdx, 45
    mov [msg], rdx
    add ebp, 1
    neg rax
  not_negate:
  push rax
  call length
  sub bx, 1
  mov ax, 1
  mov rsi, 10
  push bx
  call power
  mov rcx, rax
  pop bx
  pop rax
  call division

  mov             rax, 1
  mov             rdi, 1
  mov             rsi, msg
  push      rdi
  add        rbx, 2
  mov        [msg+ebp], byte 0x0a
  pop        rdi
  mov             edx, ebx
  syscall
  ret

_start:

pop             rax
cmp             rax, 2
jne             end

pop             rax
pop             rdi
mov             rax, 2
xor             rsi, rsi
xor             rdx, rdx
syscall

mov rdi, rax

xor rbx, rbx
xor r8, r8

read:
xor rax, rax
mov rsi, buf
mov rdx, 1
syscall

cmp rax, 0
je end

cmp [buf], word 9
jne endIF9
cmp r8, 0
je	read
add rbx, 1
mov r8, 0
jmp read
endIF9:

cmp [buf], word 10
jne endIF10
cmp r8, 0
je	read
add rbx, 1
mov r8, 0
jmp read
endIF10:

cmp [buf], word 11
jne endIF11
cmp r8, 0
je	read
add rbx, 1
mov r8, 0
jmp read
endIF11:

cmp [buf], word 12
jne endIF12
cmp r8, 0
je	read
add rbx, 1
mov r8, 0
jmp read
endIF12:

cmp [buf], word 13
jne endIF13
cmp r8, 0
je	read
add rbx, 1
mov r8, 0
jmp read
endIF13:

cmp [buf], word 32
jne endIF32
cmp r8, 0
je	read
add rbx, 1
mov r8, 0
jmp read
endIF32:

mov r8, 1

jmp read
end:
cmp r8, 1
jne print
add rbx, 1
print:
mov rax, rbx
call printNumberFromRax

mov             rax, 3
syscall

mov  rax, 60
xor rdi, rdi
syscall


section .bss
buf: resb 1
section      .data

msg          dw         "",0x0a
