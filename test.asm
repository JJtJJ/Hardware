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