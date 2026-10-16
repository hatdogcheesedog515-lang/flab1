section .data
    namePrompt db "Enter student name: "
    namePromptLen equ $ - namePrompt

    idPrompt db "Enter student ID: "
    idPromptLen equ $ - idPrompt

    gradePrompt db "Enter grade: "
    gradePromptLen equ $ - gradePrompt

    nameLabel db "Student Name: "
    nameLabelLen equ $ - nameLabel

    idLabel db "Student ID: "
    idLabelLen equ $ - idLabel

    gradeLabel db "Grade: "
    gradeLabelLen equ $ - gradeLabel

    classLabel db "Classification: "
    classLabelLen equ $ - classLabel

    excellent db "Excellent", 10
    excellentLen equ $ - excellent

    veryGood db "Very Good", 10
    veryGoodLen equ $ - veryGood

    good db "Good", 10
    goodLen equ $ - good

    passed db "Passed", 10
    passedLen equ $ - passed

    failed db "Failed", 10
    failedLen equ $ - failed

    invalidGrade db "INVALID GRADE", 10
    invalidGradeLen equ $ - invalidGrade

    newline db 10

section .bss
    nameBuffer resb 128
    idBuffer resb 32
    gradeBuffer resb 16
    gradeValue resd 1

section .text
    global _start

_start:
    mov ecx, namePrompt
    mov edx, namePromptLen
    call print

    mov ecx, nameBuffer
    mov edx, 128
    call read_line

    mov ecx, idPrompt
    mov edx, idPromptLen
    call print

    mov ecx, idBuffer
    mov edx, 32
    call read_line

    mov ecx, gradePrompt
    mov edx, gradePromptLen
    call print

    mov ecx, gradeBuffer
    mov edx, 16
    call read_line

    mov ecx, gradeBuffer
    call parse_grade

    jc invalid_input

    mov [gradeValue], eax

    mov ecx, nameLabel
    mov edx, nameLabelLen
    call print

    mov ecx, nameBuffer
    call print_string
    call print_newline

    mov ecx, idLabel
    mov edx, idLabelLen
    call print

    mov ecx, idBuffer
    call print_string
    call print_newline

    mov ecx, gradeLabel
    mov edx, gradeLabelLen
    call print

    mov ecx, gradeBuffer
    call print_string
    call print_newline

    mov ecx, classLabel
    mov edx, classLabelLen
    call print

    mov eax, [gradeValue]

    cmp eax, 90
    jae show_excellent

    cmp eax, 85
    jae show_very_good

    cmp eax, 80
    jae show_good

    cmp eax, 75
    jae show_passed

    jmp show_failed

invalid_input:
    mov ecx, nameLabel
    mov edx, nameLabelLen
    call print

    mov ecx, nameBuffer
    call print_string
    call print_newline

    mov ecx, idLabel
    mov edx, idLabelLen
    call print

    mov ecx, idBuffer
    call print_string
    call print_newline

    mov ecx, gradeLabel
    mov edx, gradeLabelLen
    call print

    mov ecx, gradeBuffer
    call print_string
    call print_newline

    mov ecx, classLabel
    mov edx, classLabelLen
    call print

    mov ecx, invalidGrade
    mov edx, invalidGradeLen
    call print
    jmp exit

show_excellent:
    mov ecx, excellent
    mov edx, excellentLen
    call print
    jmp exit

show_very_good:
    mov ecx, veryGood
    mov edx, veryGoodLen
    call print
    jmp exit

show_good:
    mov ecx, good
    mov edx, goodLen
    call print
    jmp exit

show_passed:
    mov ecx, passed
    mov edx, passedLen
    call print
    jmp exit

show_failed:
    mov ecx, failed
    mov edx, failedLen
    call print
    jmp exit

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
    je string_end
    inc edx
    jmp find_end

string_end:
    sub edx, ecx
    call print
    pop ecx
    ret

print_newline:
    mov ecx, newline
    mov edx, 1
    call print
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

check_newline:
    cmp esi, eax
    jge end_input

    cmp byte [ecx + esi], 10
    je replace_newline

    inc esi
    jmp check_newline

replace_newline:
    mov byte [ecx + esi], 0
    ret

end_input:
    mov byte [ecx + eax], 0
    ret

parse_grade:
    xor eax, eax
    xor esi, esi

parse_loop:
    mov bl, [ecx + esi]

    cmp bl, 0
    je parse_done

    cmp bl, '0'
    jb parse_invalid

    cmp bl, '9'
    ja parse_invalid

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
    cmp esi, 0
    je parse_invalid

    cmp eax, 100
    ja parse_invalid

    clc
    ret

parse_invalid:
    stc
    ret

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h