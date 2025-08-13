; guess a (psuedo?)random number between 1 - 100
; Author: Peter Firoozi (2025)
; License: MIT
; Give Credit, Do whatever you want, No Warranties.

section .data
    prompt_msg db "Guess: ", 0
    need_high db "Go Higher!", 10, 0
    need_low db "Go Lower!", 10, 0
    correct_msg db "Correct! You win!", 10, 0

section .bss
    user_guess resb 4 

section .text
global _start

_start:
    ; get time syscall
    mov rax, 201
    xor rdi, rdi
    syscall

    xor rdx, rdx
    mov rbx, 100
    div rbx ; rax = quotient, rdx = remainder
    inc rdx ; rdx now holds the random number
    mov r15, rdx ; r15 holds generated random number

    .guess:
    mov rdi, prompt_msg
    call write

    xor rdi, rdi; file descriptor stdin
    mov rsi, user_guess
    mov rdx, 4
    call read

    mov rdi, user_guess
    call atoi
    ; user guess num is now in rax
    cmp r15, rax
    je .success
    ja .needhigh
    jb .needlow

    .needlow:
        mov rdi, need_low
        call write
        jmp .guess
    .needhigh:
        mov rdi, need_high
        call write
        jmp .guess
    .success:
        mov rdi, correct_msg
        call write
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

isnum:
    ; returns 1 if dl num
    ; returns 0 if dl not num
    cmp byte dil, '0'
    jb .c_false
    cmp byte dil, '9'
    ja .c_false
    mov al, 1
    ret
    .c_false:
        xor al, al
    ret

atoi:
    ; Expects string address in rdi. Returns number in rax.
    xor rax, rax          ; Use rax for the final result
    xor r13, r13          ; Use r13 for the running total
    mov r14, 10           ; The number 10 for multiplication
    mov rcx, rdi          ; Use rcx as our string pointer

.loop:
    movzx rdi, byte [rcx]   ; Load char into rdi to pass to isnum
    call isnum              ; isnum checks the character in rdi
    cmp al, 0               ; Check the return value from isnum
    je .not_num             ; If it's not a digit, we are done

    ; It's a digit, so process it
    mov rax, r13            ; Move current total to rax for multiplication
    mul r14                 ; rax = total * 10
    mov r13, rax            ; Save the new total back to r13

    movzx rbx, byte [rcx]   ; Load a fresh copy of the character
    sub rbx, '0'            ; Convert the character in rbx to a number
    add r13, rbx            ; Add the new digit to our running total

    inc rcx                 ; Move to the next character
    jmp .loop

.not_num:
    mov rax, r13            ; Move the final total into rax for the return value
    ret

read:
    ; Expects file descriptor in rdi, buffer in rsi, count in rdx
    xor rax, rax; syscall for read 0
    syscall
    ret

write:
;    mov r15, rdi
    ; write prompt to stdout
    call strlen
    mov rsi, rdi ;copy buffer address to rsi
    mov rdx, rax ;copy len to rdx
    mov rdi, 1 ; fd = 1 = stdout
    mov rax, 1 ; syscall = 1 = write
    syscall
;    mov rdi, r15
    ret

strlen:
    ; count string length
    mov rbx, rdi
    xor rax, rax

    .l:
    cmp byte [rbx], 0
    je .done

    inc rax
    inc rbx
    jmp .l

    .done:
        ret
