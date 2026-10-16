section .data
    namePrompt   db "What is your name? "
    namePromptLen equ $ - namePrompt

    agePrompt    db "How old are you? "
    agePromptLen equ $ - agePrompt

    YearPrompt db "What is your year level? "
    YearPromptLen equ $ - YearPrompt

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

    freshmanMsg db "Freshman", 10
    freshmanLen equ $ - freshmanMsg

    sophomoreMsg db "Sophomore", 10
    sophomoreLen equ $ - sophomoreMsg

    juniorMsg db "Junior", 10
    juniorLen equ $ - juniorMsg

    seniorMsg db "Senior", 10
    seniorLen equ $ - seniorMsg

    invalidYearMsg db "INVALID YEAR LEVEL", 10
    invalidYearLen equ $ - invalidYearMsg

section .bss
    nameBuffer   resb 128
    ageBuffer    resb 16
    YearBuffer resb 8

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

    mov ecx, YearPrompt
    mov edx, YearPromptLen
    call print

    mov ecx, YearBuffer
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

    mov al, [YearBuffer]

    cmp al, '1'
    je freshman

    cmp al, '2'
    je sophomore

    cmp al, '3'
    je junior

    cmp al, '4'
    je senior

    jmp invalid_year

    freshman:
    mov ecx, freshmanMsg
    mov edx, freshmanLen
    call print
    jmp exit

    sophomore:
    mov ecx, sophomoreMsg
    mov edx, sophomoreLen
    call print
    jmp exit

    junior:
    mov ecx, juniorMsg
    mov edx, juniorLen
    call print
    jmp exit

    senior:
    mov ecx, seniorMsg
    mov edx, seniorLen
    call print
    jmp exit

show_hello:
    mov ecx, helloWord
    mov edx, helloWordLen
    call print
    jmp exit

invalid_year:
    mov ecx, invalidYearMsg
    mov edx, invalidYearLen
    call print
    jmp exit

show_world:
    mov ecx, worldWord
    mov edx, worldWordLen
    call print
    jmp exit

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