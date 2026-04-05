global _start
section .text

strlen:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	; define i
	push 0
	pop rax
	mov QWORD [rbp-16], rax
whc_0001:
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp al, bl
	setne cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0002
	lea rax, [rbp-16]
	push rax
	push QWORD [rbp-16]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0001
whe_0002:
	push QWORD [rbp-16]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

write:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	;SYSCALL
	push QWORD [GLBL_STDOUT]
	pop rdi
	push QWORD [rbp-8]
	pop rsi
	push QWORD [rbp-16]
	pop rdx
	push QWORD [GLBL_SYS_WRITE]
	pop rax
	syscall
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

print:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	; define len
	push QWORD [rbp-8]
	pop rdi
	call strlen
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	pop rsi
	pop rdi
	call write
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

println:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	mov [rbp-8], rdi
	push QWORD [rbp-8]
	pop rdi
	call print
	push STR_0003
	pop rdi
	call print
	mov rsp, rbp
	pop rbp
	ret

exit:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	mov [rbp-8], rdi
	;SYSCALL
	push QWORD [rbp-8]
	pop rdi
	push QWORD [GLBL_SYS_EXIT]
	pop rax
	syscall
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

strncmp:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	; define i
	push 0
	pop rax
	mov QWORD [rbp-32], rax
whc_0004:
	push QWORD [rbp-32]
	push QWORD [rbp-24]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0005
	push QWORD [rbp-8]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp al, bl
	setne cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0006
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
ifb0006:
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0004
whe_0005:
	push 1
	pop rax
	mov rsp, rbp
	pop rbp
	ret

munmap:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	;SYSCALL
	push QWORD [rbp-8]
	pop rdi
	push QWORD [rbp-16]
	pop rsi
	push QWORD [GLBL_SYS_MUNMAP]
	pop rax
	syscall
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

mmap:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rbp-8], rdi
	; define fd
	push 1
	pop rax

neg rax

push rax
	pop rax
	mov QWORD [rbp-16], rax
	; define offset
	push 0
	pop rax
	mov QWORD [rbp-24], rax
	; define addr
	push 0
	pop rax
	mov QWORD [rbp-32], rax
	;SYSCALL
	push QWORD [rbp-32]
	pop rdi
	push QWORD [rbp-8]
	pop rsi
	push QWORD [GLBL_PROT_READ]
	push QWORD [GLBL_PROT_WRITE]
	pop rbx
	pop rax
	or rax, rbx
	push rax
	pop rdx
	push QWORD [GLBL_MAP_PRIVATE]
	push QWORD [GLBL_MAP_ANONYMOUS]
	pop rbx
	pop rax
	or rax, rbx
	push rax
	pop r10
	push QWORD [rbp-16]
	pop r8
	push QWORD [rbp-24]
	pop r9
	push QWORD [GLBL_SYS_MMAP]
	pop rax
	syscall
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

alloc:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	; define ptr
	push QWORD [rbp-8]
	push 8
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rdi
	call mmap
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-16]
	push QWORD [rbp-8]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-16]
	push 8
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

realloc:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	; define old_size
	push QWORD [rbp-8]
	push 8
	pop rax

neg rax

push rax
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-24], rax
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0007
	push QWORD [rbp-8]
	pop rax
	mov rsp, rbp
	pop rbp
	ret
ifb0007:
	; define new_ptr
	push QWORD [rbp-16]
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-32], rax
	; define offset
	push 0
	pop rax
	mov QWORD [rbp-40], rax
whc_0008:
	push QWORD [rbp-40]
	push QWORD [rbp-24]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0009
	push QWORD [rbp-32]
	push QWORD [rbp-40]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push QWORD rbx
	push QWORD [rbp-8]
	push QWORD [rbp-40]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-40]
	push rax
	push QWORD [rbp-40]
	push 8
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0008
whe_0009:
	push QWORD [rbp-32]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

free:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	; define size
	push QWORD [rbp-8]
	push 8
	pop rax

neg rax

push rax
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-8]
	push 8
	pop rbx
	pop rax
	sub rax, rbx
	push rax
	push QWORD [rbp-16]
	push 8
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rsi
	pop rdi
	call munmap
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

open:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	mov [rbp-8], rdi
	;SYSCALL
	push QWORD [rbp-8]
	pop rdi
	push 0
	pop rsi
	push 0
	pop rdx
	push QWORD [GLBL_SYS_OPEN]
	pop rax
	syscall
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

read:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	;SYSCALL
	push QWORD [rbp-8]
	pop rdi
	push QWORD [rbp-16]
	pop rsi
	push QWORD [rbp-24]
	pop rdx
	push QWORD [GLBL_SYS_READ]
	pop rax
	syscall
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

read_file:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov [rbp-8], rdi
	; define fd
	push QWORD [rbp-8]
	pop rdi
	call open
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-16]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0010
	push STR_0011
	pop rdi
	call println
	push 1
	pop rdi
	call exit
ifb0010:
	; define buf
	push 4096
	push 100
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-24], rax
	; define to_read
	push 1024
	pop rax
	mov QWORD [rbp-32], rax
	; define chunk_c
	push 0
	pop rax
	mov QWORD [rbp-40], rax
whc_0012:
	push 1
	pop rax
	cmp rax, 0
	je whe_0013
	; define bread
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	push QWORD [rbp-40]
	push QWORD [rbp-32]
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rbx
	pop rax
	add rax, rbx
	push rax
	push QWORD [rbp-32]
	pop rdx
	pop rsi
	pop rdi
	call read
	push rax
	pop rax
	mov QWORD [rbp-48], rax
	push QWORD [rbp-48]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0014
	push STR_0015
	pop rdi
	call println
	push 1
	pop rdi
	call exit
ifb0014:
	push QWORD [rbp-48]
	push QWORD [rbp-32]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0016
	push STR_0017
	pop rdi
	call println
ifb0016:
	push QWORD [rbp-48]
	push QWORD [rbp-32]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setne cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0018
	push STR_0019
	pop rdi
	call println
	jmp whe_0013
ifb0018:
	lea rax, [rbp-40]
	push rax
	push QWORD [rbp-40]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0012
whe_0013:
	push QWORD [rbp-24]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

fmt_hex:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov [rbp-8], rdi
	; define out
	push 16
	push 3
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	; define hex
	push STR_0020
	pop rax
	mov QWORD [rbp-24], rax
	push QWORD [rbp-16]
	push 48
	pop rax ;src
	pop rbx ;dst
	mov BYTE [rbx], al
	push QWORD [rbp-16]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	push 120
	pop rax ;src
	pop rbx ;dst
	mov BYTE [rbx], al
	; define i
	push 0
	pop rax
	mov QWORD [rbp-32], rax
	; define shift
	; define idx
whc_0021:
	push QWORD [rbp-32]
	push 16
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0022
	lea rax, [rbp-40]
	push rax
	push 15
	push QWORD [rbp-32]
	pop rbx
	pop rax
	sub rax, rbx
	push rax
	push 4
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-48]
	push rax
	push QWORD [rbp-8]
	push QWORD [rbp-40]
	pop rbx
	pop rax
	mov rcx, rbx
	shr rax, cl
	push rax
	push 15
	pop rbx
	pop rax
	and rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	push 2
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	push QWORD [rbp-24]
	push QWORD [rbp-48]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rax ;src
	pop rbx ;dst
	mov BYTE [rbx], al
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0021
whe_0022:
	push QWORD [rbp-16]
	push 16
	push 3
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	push 0
	pop rax ;src
	pop rbx ;dst
	mov BYTE [rbx], al
	push QWORD [rbp-16]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

strcat:
	push rbp
	mov rbp, rsp
	sub rsp, 56
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	; define lena
	push QWORD [rbp-8]
	pop rdi
	call strlen
	push rax
	pop rax
	mov QWORD [rbp-24], rax
	; define lenb
	push QWORD [rbp-16]
	pop rdi
	call strlen
	push rax
	pop rax
	mov QWORD [rbp-32], rax
	; define new
	push QWORD [rbp-24]
	push QWORD [rbp-32]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	; define ptr
	push QWORD [rbp-40]
	pop rax
	mov QWORD [rbp-48], rax
	; define i
	push 0
	pop rax
	mov QWORD [rbp-56], rax
whc_0023:
	push QWORD [rbp-56]
	push QWORD [rbp-24]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0024
	push QWORD [rbp-48]
	push QWORD [rbp-8]
	push QWORD [rbp-56]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rax ;src
	pop rbx ;dst
	mov BYTE [rbx], al
	lea rax, [rbp-48]
	push rax
	push QWORD [rbp-48]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-56]
	push rax
	push QWORD [rbp-56]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0023
whe_0024:
	lea rax, [rbp-56]
	push rax
	push 0
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
whc_0025:
	push QWORD [rbp-56]
	push QWORD [rbp-32]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0026
	push QWORD [rbp-48]
	push QWORD [rbp-16]
	push QWORD [rbp-56]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rax ;src
	pop rbx ;dst
	mov BYTE [rbx], al
	lea rax, [rbp-48]
	push rax
	push QWORD [rbp-48]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-56]
	push rax
	push QWORD [rbp-56]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0025
whe_0026:
	push QWORD [rbp-40]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

streq:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	; define i
	push 0
	pop rax
	mov QWORD [rbp-32], rax
whc_0027:
	push QWORD [rbp-32]
	push QWORD [rbp-24]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0028
	push QWORD [rbp-8]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp al, bl
	sete cl
	push rcx
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp al, bl
	sete cl
	push rcx
	pop rbx
	pop rax
	or al, bl
	push rax
	pop ax
	cmp al, 0
	je ifb0029
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
ifb0029:
	push QWORD [rbp-8]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push QWORD rbx
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp al, bl
	setne cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0030
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
ifb0030:
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0027
whe_0028:
	push 1
	pop rax
	mov rsp, rbp
	pop rbp
	ret

check_num:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	push QWORD [rbp-24]
	push QWORD [rbp-16]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0031
	push STR_0032
	pop rdi
	call print
	push QWORD [rbp-8]
	pop rdi
	call print
	push STR_0033
	pop rdi
	call print
	push QWORD [rbp-24]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
ifb0031:
	push QWORD [rbp-24]
	push QWORD [rbp-16]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setne cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0034
	push STR_0035
	pop rdi
	call print
	push QWORD [rbp-16]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call print
	push STR_0036
	pop rdi
	call print
	push QWORD [rbp-24]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
ifb0034:
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test0:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push STR_0037
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
	; define sum
	push 0
	pop rax
	mov QWORD [rbp-16], rax
whc_0038:
	push QWORD [rbp-8]
	push 100
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0039
	lea rax, [rbp-16]
	push rax
	push QWORD [rbp-16]
	push QWORD [rbp-8]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0038
whe_0039:
	push STR_0040
	push 4950
	push QWORD [rbp-16]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

test1:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push STR_0041
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
whc_0042:
	push QWORD [rbp-8]
	push 100
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0043
	push QWORD [rbp-8]
	push 42
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0044
	jmp whe_0043
ifb0044:
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	jmp whc_0042
whe_0043:
	push STR_0045
	push 42
	push QWORD [rbp-8]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

test2:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push STR_0046
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
whc_0047:
	push QWORD [rbp-8]
	push 100
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0048
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-8]
	push 42
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0049
	jmp whc_0047
ifb0049:
	push QWORD [rbp-8]
	push 42
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop ax
	cmp al, 0
	je ifb0050
	push STR_0051
	pop rdi
	call println
	push 1
	pop rdi
	call exit
ifb0050:
	jmp whc_0047
whe_0048:
	push STR_0052
	push 100
	push QWORD [rbp-8]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

test3:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push STR_0053
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
whc_0054:
	push QWORD [rbp-8]
	push 100
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0055
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define j
	push 42
	pop rax
	mov QWORD [rbp-16], rax
	jmp whc_0054
whe_0055:
	push STR_0056
	push 100
	push QWORD [rbp-8]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_0057
	push 42
	lea rax, [rbp-8]
	push rax
	push 8
	pop rbx
	pop rax
	sub rax, rbx
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

main:
	push rbp
	mov rbp, rsp
	sub rsp, 0
	call test0
	call test1
	call test2
	call test3
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

_start:
	call main
	mov rdi, rax
	mov rax, 60
	syscall

section .rodata
	STR_0003: db "", 10, "", 0
	STR_0011: db "Error reading file", 0
	STR_0015: db "No bytes read :(", 0
	STR_0017: db "there is more to read...", 0
	STR_0019: db "there is NO more to read!", 0
	STR_0020: db "0123456789abcdef", 0
	STR_0032: db "OK: expected: (", 0
	STR_0033: db "), got: ", 0
	STR_0035: db "FAIL: expected ", 0
	STR_0036: db " but got ", 0
	STR_0037: db "====test0====", 0
	STR_0040: db "0x1356", 0
	STR_0041: db "====test1====", 0
	STR_0045: db "0x2a", 0
	STR_0046: db "====test2====", 0
	STR_0051: db "failed!", 0
	STR_0052: db "0x64", 0
	STR_0053: db "====test3====", 0
	STR_0056: db "0x64", 0
	STR_0057: db "0x2a", 0

section .data
	GLBL_SYS_READ: dq 0
	GLBL_SYS_WRITE: dq 1
	GLBL_SYS_OPEN: dq 2
	GLBL_SYS_MMAP: dq 9
	GLBL_SYS_MUNMAP: dq 11
	GLBL_SYS_EXIT: dq 60
	GLBL_PROT_READ: dq 1
	GLBL_PROT_WRITE: dq 3
	GLBL_MAP_PRIVATE: dq 2
	GLBL_MAP_ANONYMOUS: dq 32
	GLBL_STDOUT: dq 1
