format PE console

entry start

include 'win32a.inc'


;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector A? ', 0
        strVectorA   db 'Vector A:', 10, 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVectorB   db 'Vector B:', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0         ; Size of the vector A
        i            dd ?         ; Loop iterations counter
        tmp          dd ?
        tmpStack     dd ?
        vecA         rd 100
        vecB         rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable

        start:
        ; 1) vector A input
          call VectorInput

        ; 2) write vector A
          push strVectorA
          call [printf]
          call VectorOutA

        ; 3) get vector B
          call VectorB

        ; 4) write vector B
          push strVectorB
          call [printf]
          call VectorOutB

        finish:
        ; Wait for user to press any key
          call [getch]

        ; Exit the program
          push 0
          call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; fail size
        push [vec_size]
        push strIncorSize
        call [printf]

        call [getch]

        push 0
        call [ExitProcess]
; else continue...
getVector:
        push strVectorA
        call [printf]
        add esp, 4

        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorB:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB            ; ebx = &vecB
        mov edx, vecA            ; edx = &vecA

vecBLoop:

        cmp ecx, [vec_size]
        je endSumVector      ; to end of loop

        mov [i], ecx

        mov eax, 5
        cmp [edx], eax
        jg greaterThan5

        mov eax, -5
        cmp eax, [edx]
        jg lessThanNeg5

        ;else:
        mov eax, 0
        mov [ebx], eax

endIf:

        mov ecx, [i]
        inc ecx
        add ebx, 4
        add edx, 4

        jmp vecBLoop

greaterThan5:
        mov ecx, [edx]
        add ecx, eax
        mov [ebx], ecx

        jmp endIf

lessThanNeg5:
        mov ecx, [edx]
        add ecx, eax
        mov [ebx], ecx

        jmp endIf

endSumVector:
        ret

;--------------------------------------------------------------------------
VectorOutA:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA
putVecALoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVectorA      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecALoop

endOutputVectorA:
        mov esp, [tmpStack]
        ret

;--------------------------------------------------------------------------
VectorOutB:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB            ; ebx = &vecA
putVecBLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVectorB      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecBLoop

endOutputVectorB:
        mov esp, [tmpStack]
        ret

;--------------------------------------------------------------------------
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

