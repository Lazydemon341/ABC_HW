format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strInputNum   db 'Input an unsigned dword: ', 0
        strUintFormat db '%u', 0
        strIncorrectInput db 'The input is not a number!', 10, 0
        strPressAnyKey db 10, 'Press any key to exit...', 0

        two             dd 2
        powerOfTwo      dd 1 ; Power of two.
        inputNum        dd ? ; Number that the user inputs.
        counter         dd 0 ; Number of Cullen numbers that are not greater than inputNum.

        null = 0

;--------------------------------------------------------------------------
section '.code' code readable executable

start:
        ; Input
        push strInputNum
        call [printf]

        push inputNum
        push strUintFormat
        call [scanf]

        ; Check for correct input
        call CheckInput

        ; Calculate result
        call FindCullenNumbersQuantityLoop

        ; Output
        push [counter]
        push strUintFormat
        call [printf]

finish:
        ; Wait for user to press a key
        push strPressAnyKey
        call [printf]

        call [getch]

        push null
        call [ExitProcess]

;--------------------------------------------------------------------------------------

CheckInput:
        cmp eax, 1           ; Check that user input is one number
        jne incorrectInput

        ;Else:
        ret

incorrectInput:
        push strIncorrectInput     ; Print a message and finish the program
        call [printf]

        jmp finish

;--------------------------------------------------------------------------------------

FindCullenNumbersQuantityLoop:
        mov [powerOfTwo], 1
        mov [counter], null

        mov ecx, 1

continueLoop:

        ; Calculating C_n (Number of cullen)
        mov eax, [counter]
        mul [powerOfTwo]   ; mul writes result to eax and edx

        ; If edx is not null then result of mull is greater than a dword
        cmp edx, null
        jne endOfLoop

        ; Else continue
        mov ebx, eax
        inc ebx

        ; Check if current Cullen number is not greater than inputNum
        cmp ebx, [inputNum]
        ja endOfLoop

        ; Else increase counter and continue
        add [counter], 1

        mov eax, [two]
        mul [powerOfTwo]
        mov [powerOfTwo], eax   ; Calculate power of two

        ; So that the loop won't finish early
        inc ecx

endOfLoop:
        loop continueLoop
        ret


;-----------------------------------------------------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'

    import kernel,\
           ExitProcess, 'ExitProcess'

    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'