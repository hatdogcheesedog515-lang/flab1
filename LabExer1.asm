BITS 32
global _start

section .data
    menu db '----------------------------------',10
         db 'MENU',10,'[A]Add',10,'[S]Subtract',10
         db '[M]Multiply',10,'[D]Divide',10
         db '----------------------------------',10,0
    choice_msg db 'Enter your choice: ',0
    first_msg db 10,'Enter first number: ',0
    second_msg db 'Enter second number: ',0
    sum_msg db 'The sum is ',0
    difference_msg db 'The difference is ',0
    product_msg db 'The product is ',0
    quotient_msg db 'The quotient is ',0
    remainder_msg db 'The remainder is ',0
    again_msg db 10,'Do you want to try again (Y/N): ',0
    invalid_choice db 'Invalid choice. Enter A, S, M, or D.',10,0
    invalid_number db 'Invalid number. Enter 1 or 2 digits (0-99).',10,0
    invalid_again db 'Please enter Y or N.',10,0
    divide_zero db 'Cannot divide by zero.',10,0
    goodbye db 'Program terminated.',10,0
    newline db 10,0
    minus_sign db '-',0
    clear_code db 27,'[2J',27,'[H',0

section .bss
    input resb 16
    one_char resb 1
    number_buffer resb 12
    choice resb 1
    first_number resd 1
    second_number resd 1
    remainder resd 1

section .text
_start:
.menu:
    call clear_screen
    mov ecx, menu
    call print

.choose:
    mov ecx, choice_msg
    call print
    call read_line
    cmp eax, 1
    jne .bad_choice
    mov al, [input]
    and al, 0DFh                  
    cmp al, 'A'
    je .get_numbers
    cmp al, 'S'
    je .get_numbers
    cmp al, 'M'
    je .get_numbers
    cmp al, 'D'
    je .get_numbers
.bad_choice:
    mov ecx, invalid_choice
    call print
    jmp .choose

.get_numbers:
    mov [choice], al
    mov ecx, first_msg
    call read_number
    mov [first_number], eax
    mov ecx, second_msg
    call read_number
    mov [second_number], eax

    cmp byte [choice], 'A'
    je .add
    cmp byte [choice], 'S'
    je .subtract
    cmp byte [choice], 'M'
    je .multiply
    call divide_numbers
    jmp .again
.add:
    call add_numbers
    jmp .again
.subtract:
    call subtract_numbers
    jmp .again
.multiply:
    call multiply_numbers

.again:
    mov ecx, again_msg
    call print
    call read_line
    cmp eax, 1
    jne .bad_again
    mov al, [input]
    and al, 0DFh
    cmp al, 'Y'
    je .menu                     
    cmp al, 'N'
    je exit_program
.bad_again:
    mov ecx, invalid_again
    call print
    jmp .again

add_numbers:
    mov eax, [first_number]
    add eax, [second_number]
    mov ecx, sum_msg
    call show_result
    ret

subtract_numbers:
    mov eax, [first_number]
    sub eax, [second_number]
    mov ecx, difference_msg
    call show_result
    ret

multiply_numbers:
    mov eax, [first_number]
    imul eax, [second_number]
    mov ecx, product_msg
    call show_result
    ret

divide_numbers:
    cmp dword [second_number], 0
    je .zero
    mov eax, [first_number]
    xor edx, edx                  
    div dword [second_number]     
    mov [remainder], edx
    mov ecx, quotient_msg
    call show_result
    mov eax, [remainder]
    mov ecx, remainder_msg
    call show_result
    ret
.zero:
    mov ecx, divide_zero
    call print
    ret

show_result:
    call print                   
    call print_number
    mov ecx, newline
    call print
    ret

print:
    pushad
    xor edx, edx
.length:
    cmp byte [ecx + edx], 0
    je .write
    inc edx
    jmp .length
.write:
    mov eax, 4                    
    mov ebx, 1                    
    int 0x80
    popad
    ret

read_line:
    push ebx
    push ecx
    push esi
    push edi
    xor esi, esi
    xor edi, edi
.read:
    mov eax, 3                    
    xor ebx, ebx                  
    mov ecx, one_char
    mov edx, 1
    int 0x80
    cmp eax, 1
    jne exit_program             
    mov al, [one_char]
    cmp al, 10                    
    je .done
    cmp al, 13                    
    je .read
    cmp esi, 15
    jae .too_long
    mov [input + esi], al
    inc esi
    jmp .read
.too_long:
    mov edi, 1                   
    jmp .read
.done:
    mov byte [input + esi], 0
    mov eax, esi
    mov edx, edi
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret

read_number:
    push ebx
    push esi
    push edi
    mov edi, ecx                 
.retry:
    mov ecx, edi
    call print
    call read_line
    test edx, edx
    jnz .invalid
    cmp eax, 1
    jb .invalid
    cmp eax, 2
    ja .invalid
    mov esi, input
    xor eax, eax
.convert:
    movzx ebx, byte [esi]
    test ebx, ebx
    jz .valid
    cmp ebx, '0'
    jb .invalid
    cmp ebx, '9'
    ja .invalid
    sub ebx, '0'                  
    imul eax, eax, 10             
    add eax, ebx
    inc esi
    jmp .convert
.invalid:
    mov ecx, invalid_number
    call print
    jmp .retry
.valid:
    pop edi
    pop esi
    pop ebx
    ret

print_number:
    pushad
    test eax, eax
    jns .positive
    mov ecx, minus_sign
    call print
    neg eax
.positive:
    mov edi, number_buffer + 11
    mov byte [edi], 0
    mov ebx, 10
.digit:
    xor edx, edx
    div ebx                       
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .digit
    mov ecx, edi
    call print
    popad
    ret

clear_screen:
    mov ecx, clear_code            
    call print
    ret

exit_program:
    mov ecx, goodbye
    call print
    mov eax, 1                   
    xor ebx, ebx
    int 0x80