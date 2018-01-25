; ---------------------------------------------------------------------------
; Tell compiler to generate 64 bit code
; ---------------------------------------------------------------------------
bits 64

; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------
NULL EQU 0
STD_OUTPUT_HANDLE EQU -11

; ---------------------------------------------------------------------------
; Data segment:
; ---------------------------------------------------------------------------
section .data use64
  Message: db 'hello!', 10
  MessageLength  EQU $-Message

; ---------------------------------------------------------------------------
; Uninitialized data segment
; ---------------------------------------------------------------------------
section .bss
alignb 8
   StandardHandle resq 1
   Written        resq 1

; ---------------------------------------------------------------------------
; Code segment:
; ---------------------------------------------------------------------------
section .text use64

        global main
        extern  ExitProcess
        extern  GetStdHandle
        extern  WriteFile

; --------------------------------------------------------------------------
; Start of Main Program
; ---------------------------------------------------------------------------
main:
  and   RSP, 0FFFFFFFFFFFFFFF0h                  ; Align the stack to a multiple of 16 bytes

  sub   RSP, 32                                  ; 32 bytes of shadow space
  mov   RCX, STD_OUTPUT_HANDLE
  call  GetStdHandle
  mov   qword [REL StandardHandle], RAX
  add   RSP, 32                                  ; Remove the 32 bytes

  sub   RSP, 32 + 8 + 8                          ; Shadow space + 5th parameter + align stack
                                                 ; to a multiple of 16 bytes
  mov   RCX, qword [REL StandardHandle]          ; 1st parameter
  lea   RDX, [REL Message]                       ; 2nd parameter
  mov   R8, MessageLength                        ; 3rd parameter
  lea   R9, [REL Written]                        ; 4th parameter
  mov   qword [RSP + 4 * 8], NULL                ; 5th parameter
  call  WriteFile                                ; Output can be redirect to a file using >
  add   RSP, 48                                  ; Remove the 48 bytes

  xor   RCX, RCX

  ; stop from closing
  here:
          jmp here

  call  ExitProcess
