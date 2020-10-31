format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strInputNum   db 'Input an unsigned dword: ', 0
        strUintFormat db '%u', 0
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
        push strUintFormat
        call [scanf]

        call CheckInput

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

        mov ecx, 1

continueLoop:

        ; Calculating C_n (Number of cullen)
        mov eax, [counter]
        mul [powerOfTwo]   ; mul writes result to eax and edx

        ; If edx is not null then result of mull is greater than a dword
        cmp edx, 0
        jne endOfLoop

        ; Else continue
        mov ebx, eax
        inc ebx

        ; Check if current Cullen number is not greater than inputNum
        cmp ebx, [inputNum]
        jg endOfLoop

        ; Else increase counter and continue
        add [counter], 1

        mov eax, [two]
        mul [powerOfTwo]
        mov [powerOfTwo], eax   ; Calculate power of two

        inc ecx

endOfLoop:
        loop continueLoop
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