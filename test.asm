segment .text
        global  _start
_start:

main:
        mov  rax, 5
        push rax
        call test

        call os_return

test:
        push rbp
        mov  rbp, rsp

        push rax
        push rbx
        push rcx
        push rdx

        mov  rbx, [rbp + 16]
        mov  rdx, 10
        mov  rcx, 1

        mov  rax, rbx
        add  rax, rcx

loop:
        imul rdx, 2
        cmp  rdx, 100
        jl   loop

        cmp  rbx, 10
        jne  end

        mov  rax, 140

end:
        push rax
        call output_int
        call output_tab
        add  rsp 8

        push rbx
        call output_int
        call output_tab
        add  rsp 8

        push rcx
        call output_int
        call output_tab
        add  rsp 8

        push rdx
        call output_int
        call output_tab
        add  rsp 8

        pop  rbx
        pop  rcx
        pop  rbx
        pop  rax
        pop  rbp
        ret



os_return:
        mov  rax, EXIT          ; Linux system call 1 i.e. exit ()
        mov  rbx, 0             ; Error code 0 i.e. no errors
        int  LINUX              ; Interrupt Linux kernel

output_char:                    ; void output_char (ch)
        push rax
        push rbx
        push rcx
        push rdx
        push r8                ; r8..r11 are altered by Linux kernel interrupt
        push r9
        push r10
        push r11
        push qword [octetbuffer] ; (just to make output_char() re-entrant...)

        mov  rax, WRITE         ; Linux system call 4; i.e. write ()
        mov  rbx, STDOUT        ; File descriptor 1 i.e. standard output
        mov  rcx, [rsp+80]      ; fetch char from non-I/O-accessible segment
        mov  [octetbuffer], rcx ; load into 1-octet buffer
        lea  rcx, [octetbuffer] ; Address of 1-octet buffer
        mov  rdx, 1             ; Output 1 character only
        int  LINUX              ; Interrupt Linux kernel

        pop qword [octetbuffer]
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        pop  rdx
        pop  rcx
        pop  rbx
        pop  rax
        ret

        output_newline:                 ; void output_newline ()
       push qword LF
       call output_char
       add rsp, 8
       ret

; ------------------------

output_tab:                     ; void output_tab ()
       push qword TAB
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_minus:                   ; void output_minus()
       push qword MINUS
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_int:                     ; void output_int (int N)
       push rbp
       mov  rbp, rsp

       ; rax=N then N/10, rdx=N%10, rbx=10

       push rax                ; save registers
       push rbx
       push rdx

       cmp  qword [rbp+16], 0 ; minus sign for negative numbers
       jge  L88

       call output_minus
       neg  qword [rbp+16]

L88:
       mov  rax, [rbp+16]       ; rax = N
       mov  rdx, 0              ; rdx:rax = N (unsigned equivalent of "cqo")
       mov  rbx, 10
       idiv rbx                ; rax=N/10, rdx=N%10

       cmp  rax, 0              ; skip if N<10
       je   L99

       push rax                ; output.int (N / 10)
       call output_int
       add  rsp, 8

L99:
       add  rdx, '0'           ; output char for digit N % 10
       push rdx
       call output_char
       add  rsp, 8

       pop  rdx                ; restore registers
       pop  rbx
       pop  rax
       pop  rbp
       ret