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

        vec_size     dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec          rd 100



;--------------------------------------------------------------------------
section '.code' code readable executable

        start:
        ; 1) vector A input
          call VectorInput
        ; 2) get vector B
          call VectorB
        ; 3) out of VectorB
          push strVectorB
          call [printf]
        ; 4) write vector B
          call VectorOut

        finish:
          call [getch]

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
        mov ebx, vec            ; ebx = &vec
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
        mov ebx, vec            ; ebx = &vec
vecBLoop:

        cmp ecx, [vec_size]
        je endSumVector      ; to end of loop

        ;mov eax, [sum]
        ;add eax, [ebx]
        ;mov [sum], eax

        mov eax, 5
        cmp [ebx], eax
        jg greaterThan5

        mov eax, -5
        cmp eax, [ebx]
        jg lessThanNeg5

        ;else:
        mov edx, [ebx]
        mov edx, 0
        mov [ebx], edx

        endIf:

        inc ecx
        add ebx, 4

        jmp vecBLoop

greaterThan5:
        mov edx, [ebx]
        mov eax, 5
        add edx, eax
        mov [ebx], edx

        jmp endIf

lessThanNeg5:
        mov edx, [ebx]
        mov eax, 5
        sub edx, eax
        mov [ebx], edx

        jmp endIf

endSumVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
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
        jmp putVecLoop
endOutputVector:
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
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'

