format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strInputNum   db 'Input an unsigned dword: ', 0
        strUintFormat db '%u', 0
        strNumFormat  db '%d', 0
        strIncorrectInput db 'The input is not a number!', 10, 0
        strPressAnyKey db 10, 'Press any key to exit...', 0


        null = 0

        inputNum        dd ? ; Number that the user inputs.
        two             dd 2
        powerOfTwo      dd ? ; Power of two.
        counter         dd ? ; Number of Cullen numbers that are not greater than inputNum.

;--------------------------------------------------------------------------
section '.code' code readable executable

start:
        push strInputNum
        call [printf]

        push inputNum
        push strNumFormat
        call [scanf]

        call CheckInput

        push [inputNum]
        push strNumFormat
        call[printf]

        call FindCullenNumbersQuantityLoop

        push [counter]
        push strUintFormat
        call [printf]

finish:
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
        mov [counter], 0

continueLoop:

        ; Calculating C_n (Number of cullen)
        mov ebx, [powerOfTwo]
        mov eax, [counter]
        mul ebx   ; mul writes result to edx
        mov ebx, eax
        inc ebx

        ; Check if current Cullen number is not greater than inputNum
        cmp ebx, inputNum
        jg endOfLoop

        ; Else:
        add [counter], 1    ; Increase counter

        mov eax, [two]
        mul [powerOfTwo]
        mov [powerOfTwo], eax   ; Calculate power of two

        jmp continueLoop

endOfLoop:
        ret


;-------------------------------third act - including HeapApi--------------------------
                                                 
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