                section         .text

                global          _start

fail:           ud2

print_new_line:
                mov             dl, 10
                mov             [trash_buff], dl
                mov             rax, 1
                mov             rdi, 0
                mov             rdx, 1
                mov             rsi, trash_buff
                syscall
                ret     
         
write_number:
                mov             r10, 1
                cmp             rax, 0
                jnl             write_number1
                mov             r10, -1
                cmp             rax, -2147483648
                jne             write_number1
                mov             rax, min_value
                mov             rdx, min_value_size
                mov             rsi, rax
                jmp             write_number_final
write_number1:
                mov             rbx, rax
                sar             rbx, 31
                xor             rax, rbx
                sub             rax, rbx
                mov             rbx, 10
                mov             rcx, 0
write_number_for1:
                mov             rdx, 0
                div             rbx
                add             rdx, '0'
                push            rdx
                inc             rcx
                cmp             rax, 0
                jne             write_number_for1

                mov             rdx, 0
                cmp             r10, -1
                jne             write_number_for2
                push            '-'
                inc             rcx
write_number_for2:
                pop             rbx
                mov             [trash_buff, rdx], rbx
                inc             rdx
                loop            write_number_for2
                mov             rsi, trash_buff
                
write_number_final:
                mov             rax, 1
                mov             rdi, 0
                syscall
                ret             
 
 
 
_start:
                
                pop             rax
                cmp             rax, 2
                jne             fail
                pop             rax
                pop             rdi
                
                mov             rdx, 0
                mov             rax, 2
                mov             rsi, 0
                syscall
                mov             rsi, buff
                mov             rbx, 0
                mov             rdi, rax
                mov             r8, 1
                mov             r10, 1
main_for1:
                mov             rax, 0
                mov             rdx, 1024
                syscall
                cmp             rax, 0
                je              main_for_exit
                mov             rcx, rax
                mov             rax, 0
main_for2:
                mov             rdx, [buff, rax]
                cmp             dl, 10
                je              check_true
                cmp             dl, 9
                je              check_true
                cmp             dl, 0xd
                je              check_true
                cmp             dl, 0xa0
                je              check_true
                cmp             dl, ' '
                je              check_true
                mov             r10, 0
                jmp             check_false
check_true:
                inc             rbx
                cmp             r10, 1
                mov             r10, 1
                jne             check_false
check_true1:
                dec             rbx
check_false:
                inc             rax
                loop            main_for2
                jmp             main_for1
main_for_exit:               
                mov             rax, rbx
                call            write_number
                call            print_new_line

exit:
                mov             rax, 60
                xor             rdi, rdi
                syscall

                section         .rodata
min_value:       db              "-2147483648"
min_value_size: equ             $ - min_value
                section         .bss
buff:           resb            1024
trash_buff:     resb            16
