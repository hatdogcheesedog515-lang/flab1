section .data
    namePrompt   db "What is your name? "
    namePromptLen equ $ - namePrompt

    agePrompt    db "How old are you? "
    agePromptLen equ $ - agePrompt

    genderPrompt db "What is your gender? "
    genderPromptLen equ $ - genderPrompt

    helloMsg     db "Hello "
    helloMsgLen  equ $ - helloMsg

    ageMsg       db "You are "
    ageMsgLen    equ $ - ageMsg

    yearsMsg     db " years old", 10
    yearsMsgLen  equ $ - yearsMsg

    helloWord    db "Hello", 10
    helloWordLen equ $ - helloWord

    worldWord    db "World", 10
    worldWordLen equ $ - worldWord

    invalidWord  db "INVALID", 10
    invalidLen   equ $ - invalidWord

section .bss
    nameBuffer   resb 128
    ageBuffer    resb 16
    genderBuffer resb 8

section .text
    global _start

_start:
    mov ecx, namePrompt
    mov edx, namePromptLen
    call print

    mov ecx, nameBuffer
    mov edx, 128
    call read_line

    mov ecx, agePrompt
    mov edx, agePromptLen
    call print

    mov ecx, ageBuffer
    mov edx, 16
    call read_line

    mov ecx, genderPrompt
    mov edx, genderPromptLen
    call print

    mov ecx, genderBuffer
    mov edx, 8
    call read_line

    mov ecx, helloMsg
    mov edx, helloMsgLen
    call print

    mov ecx, nameBuffer
    call print_string

    call newline

    mov ecx, ageMsg
    mov edx, ageMsgLen
    call print

    mov ecx, ageBuffer
    call print_string

    mov ecx, yearsMsg
    mov edx, yearsMsgLen
    call print

    mov al, [genderBuffer]
    and al, 0DFh

    cmp al, 'M'
    je show_hello

    cmp al, 'F'
    je show_world

    jmp show_invalid

show_hello:
    mov ecx, helloWord
    mov edx, helloWordLen
    call print
    jmp exit

show_world:
    mov ecx, worldWord
    mov edx, worldWordLen
    call print
    jmp exit

show_invalid:
    mov ecx, invalidWord
    mov edx, invalidLen
    call print

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h

print:
    mov eax, 4
    mov ebx, 1
    int 80h
    ret

print_string:
    push ecx
    mov edx, ecx

find_end:
    cmp byte [edx], 0
    je string_found
    inc edx
    jmp find_end

string_found:
    sub edx, ecx
    call print
    pop ecx
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

remove_newline:
    cmp esi, eax
    jge finish_input

    cmp byte [ecx + esi], 10
    je replace_newline

    inc esi
    jmp remove_newline

replace_newline:
    mov byte [ecx + esi], 0
    ret

finish_input:
    mov byte [ecx + eax], 0
    ret

newline:
    push ecx
    push edx

    mov ecx, yearsMsg + 10
    mov edx, 1
    call print

    pop edx
    pop ecx
    ret