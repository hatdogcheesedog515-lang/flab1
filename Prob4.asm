section .data
    namePrompt db "Enter account name: "
    namePromptLen equ $ - namePrompt

    pinPrompt db "Enter PIN: "
    pinPromptLen equ $ - pinPrompt

    amountPrompt db "Enter withdrawal amount: "
    amountPromptLen equ $ - amountPrompt

    accessGranted db "ACCESS GRANTED", 10
    accessGrantedLen equ $ - accessGranted

    accessDenied db "ACCESS DENIED", 10
    accessDeniedLen equ $ - accessDenied

    balanceMsg db "Current Balance: PHP "
    balanceMsgLen equ $ - balanceMsg

    invalidAmount db "INVALID AMOUNT", 10
    invalidAmountLen equ $ - invalidAmount

    insufficientMsg db "INSUFFICIENT FUNDS", 10
    insufficientLen equ $ - insufficientMsg

    multipleMsg db "AMOUNT MUST BE A MULTIPLE OF 100", 10
    multipleLen equ $ - multipleMsg

    successMsg db "WITHDRAWAL SUCCESSFUL", 10
    successLen equ $ - successMsg

    withdrawnMsg db "Amount Withdrawn: PHP "
    withdrawnLen equ $ - withdrawnMsg

    remainingMsg db "Remaining Balance: PHP "
    remainingLen equ $ - remainingMsg

    newline db 10

section .bss
    nameBuffer resb 128
    pinBuffer resb 16
    amountBuffer resb 16
    numberBuffer resb 16

    balance resd 1
    withdrawal resd 1

section .text
    global _start

_start:
    mov dword [balance], 10000

    mov ecx, namePrompt
    mov edx, namePromptLen
    call print

    mov ecx, nameBuffer
    mov edx, 128
    call read_line

    mov ecx, pinPrompt
    mov edx, pinPromptLen
    call print

    mov ecx, pinBuffer
    mov edx, 16
    call read_line

    mov ecx, pinBuffer
    call parse_number

    jc denied

    cmp eax, 1234
    jne denied

    mov ecx, accessGranted
    mov edx, accessGrantedLen
    call print

    mov ecx, balanceMsg
    mov edx, balanceMsgLen
    call print

    mov eax, [balance]
    call print_number
    call print_newline

    mov ecx, amountPrompt
    mov edx, amountPromptLen
    call print

    mov ecx, amountBuffer
    mov edx, 16
    call read_line

    mov ecx, amountBuffer
    call parse_number

    jc invalid_amount

    cmp eax, 0
    jle invalid_amount

    mov [withdrawal], eax

    cmp eax, [balance]
    ja insufficient_funds

    xor edx, edx
    mov ebx, 100
    div ebx

    cmp edx, 0
    jne invalid_multiple

    mov eax, [withdrawal]
    sub [balance], eax

    mov ecx, successMsg
    mov edx, successLen
    call print

    mov ecx, withdrawnMsg
    mov edx, withdrawnLen
    call print

    mov eax, [withdrawal]
    call print_number
    call print_newline

    mov ecx, remainingMsg
    mov edx, remainingLen
    call print

    mov eax, [balance]
    call print_number
    call print_newline

    jmp exit

denied:
    mov ecx, accessDenied
    mov edx, accessDeniedLen
    call print
    jmp exit

invalid_amount:
    mov ecx, invalidAmount
    mov edx, invalidAmountLen
    call print
    jmp exit

insufficient_funds:
    mov ecx, insufficientMsg
    mov edx, insufficientLen
    call print
    jmp exit

invalid_multiple:
    mov ecx, multipleMsg
    mov edx, multipleLen
    call print
    jmp exit

parse_number:
    xor eax, eax
    xor esi, esi

parse_loop:
    movzx ebx, byte [ecx + esi]

    cmp ebx, 0
    je parse_done

    cmp ebx, '0'
    jb parse_invalid

    cmp ebx, '9'
    ja parse_invalid

    sub ebx, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
    cmp esi, 0
    je parse_invalid

    clc
    ret

parse_invalid:
    stc
    ret

print_number:
    cmp eax, 0
    jne convert_number

    mov byte [numberBuffer], '0'
    mov ecx, numberBuffer
    mov edx, 1
    call print
    ret

convert_number:
    mov edi, numberBuffer + 16
    xor ecx, ecx
    mov ebx, 10

number_loop:
    xor edx, edx
    div ebx

    dec edi
    add dl, '0'
    mov [edi], dl
    inc ecx

    cmp eax, 0
    jne number_loop

    mov edx, ecx
    mov ecx, edi
    call print
    ret

print:
    mov eax, 4
    mov ebx, 1
    int 80h
    ret

read_line:
    push ecx
    push edx

    mov eax, 3
    mov ebx, 0
    int 80h

    pop edx
    pop ecx

    xor esi, esi

find_newline:
    cmp esi, eax
    jge end_input

    cmp byte [ecx + esi], 10
    je replace_newline

    inc esi
    jmp find_newline

replace_newline:
    mov byte [ecx + esi], 0
    ret

end_input:
    mov byte [ecx + eax], 0
    ret

print_newline:
    mov ecx, newline
    mov edx, 1
    call print
    ret

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h