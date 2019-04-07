SYS_READ    equ     0x00
SYS_WRITE   equ     0x01
SYS_OPEN    equ     0x02
SYS_CLOSE   equ     0x03
SYS_EXIT    equ     0x3c

STDOUT      equ     0x01


section	.text
   global _start

;
; Macro to exit
;
;   %1      return code
;
%macro exit 1
    mov     rax, SYS_CLOSE
    mov     rdi, [input_fd]
    syscall
    mov     rax, SYS_EXIT
    mov     rdi, %1
    syscall
%endmacro

;
; Macro to read
;
;   %1      buffer pointer
;   %2      buffer length
;
%macro read 2
    mov     rax, SYS_READ
    mov     rdi, [input_fd]
    mov     rsi, %1
    mov     rdx, %2
    syscall
    cmp     rax, 0
    jl      _reading_failure_error
%endmacro

;
; Macro to write
;
;   %1      buffer pointer
;   %2      buffer length
;
%macro write 2
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, %1
    mov     rdx, %2
    syscall
    cmp     rax, 0
    jl      _writing_failure_error
%endmacro

;
; Macrho to jump if in range
;
; %1	register to check
; %2	left edge
; %3	right edge
; %4	target label
;
%macro jump_not_in_range 4
    cmp     %1, %2
    jl      %4
    cmp     %1, %3
    jg      %4
%endmacro

;
; Function to parse rax to buf
;
;   rax     input
;   rcx     radix
;   rdx     digit
;   rdi     length
;
parse:
    mov     rcx, 10
    xor     rdi, rdi
parse_loop1:
    xor     rdx, rdx
    div     rcx
    add     dl, '0'
    push    rdx
    inc     rdi
    cmp     rax, 0
    jg      parse_loop1

    mov     [buf_len], rdi
    xor     rcx, rcx
parse_loop2:
    pop     r8
    mov     [buf + rcx], r8b
    inc     rcx
    dec     rdi
    cmp     rdi, 0
    jg      parse_loop2

    ret

;
; Function to write rax value
;
write_rax:
    call    parse
    write   endl, endl.len
    write   buf, [buf_len]
    write   endl, endl.len
    ret

;
; Function to count words
;
; r8	ans
; r9	iterator
; r10   current byte
; r11   flag
;
count_words:
    xor     r8, r8
    mov     rax, cluster
    mov     [buf_len], rax
    mov     r11, 1

.loop:
    push    r11
    read    buf, [buf_len]
    pop     r11
    je      .final_word
    xor     r9, r9

.check_byte:
    mov     r10, [buf + r9]

    jump_not_in_range r10b, 0x09, 0x0d, .not_group_1

    mov     r11, 1
    jmp     .check_byte_end

.not_group_1:
    jump_not_in_range r10b, 0x20, 0x20, .not_whitespace

    mov     r11, 1
    jmp     .check_byte_end

.not_whitespace:
    cmp     r11, 1
    jne     .check_byte_end
    inc     r8
    mov     r11, 0

.check_byte_end:
    inc     r9
    cmp     r9, rax
    jl      .check_byte
    jmp     .loop

.final_word:
    cmp     r11, 0
    jne     .end
    inc     r8

.end:
    mov     rax, r8
    ret

;
; Entry point
;
_start:
    pop     rax
    cmp     rax, 2
    jne     _wrong_args_error

    pop     rax
    mov     rax, SYS_OPEN
    pop     rdi
    xor     rsi, rsi
    xor     rdx, rdx
    syscall

    cmp     rax, 0
    jl      _input_init_failure_error
    mov     [input_fd], rax

    call    count_words
    call    write_rax
    exit    0

;
; Error exits
;
_wrong_args_error:
    write   input_args_failure_msg, input_args_failure_msg_len
    write   endl, endl.len
    exit    -1

_input_init_failure_error:
    write   input_init_failure_msg, input_init_failure_msg_len
    write   endl, endl.len
    exit    -1

_reading_failure_error:
    write   reading_failure_msg, reading_failure_msg_len
    write   endl, endl.len
    exit    -1

_writing_failure_error:
    write   writing_failure_msg, writing_failure_msg_len
    write   endl, endl.len
    exit    -1


section .rodata

cluster     equ     1024
endl        db      10
.len        equ     1

input_args_failure_msg      db      "usage: count_words INPUT_FILE"
input_args_failure_msg_len  equ     $ - input_args_failure_msg
input_init_failure_msg      db      "input init failure"
input_init_failure_msg_len  equ     $ - input_init_failure_msg
reading_failure_msg         db      "reading failure"
reading_failure_msg_len     equ     $ - reading_failure_msg
writing_failure_msg         db      "writing failure"
writing_failure_msg_len     equ     $ - writing_failure_msg


section .bss

buf         resb    1024
buf_len     resq    1
input_fd    resq    1
