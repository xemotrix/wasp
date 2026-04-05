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
	push rbx
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
	push rbx
	pop rax
	push QWORD [rax]
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
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
	push rbx
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
	push rbx
	push QWORD [rbp-8]
	push QWORD [rbp-40]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
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
	push rbx
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
	push rbx
	push QWORD [rbp-24]
	push QWORD [rbp-48]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
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
	push rbx
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
	push rbx
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
	push rbx
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
	push rbx
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
	push rbx
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
	push rbx
	pop rax
	push QWORD [rax]
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
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
	mov rsp, rbp
	pop rbp
	ret

test0:
	push rbp
	mov rbp, rsp
	sub rsp, 88
	push STR_0037
	pop rdi
	call println
	; define i
	lea rax, [rbp-32]
	push rax
	mov rax, 54491065313
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	mov rax, 54491065314
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	mov rax, 54491065315
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0038
	mov rax, 54491065313
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0039
	mov rax, 54491065314
	push rax
	lea rax, [rbp-24]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0040
	mov rax, 54491065315
	push rax
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	; define new_lmao
	lea rax, [rbp-56]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-48]
	push rax
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0041
	push 15
	lea rax, [rbp-56]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0042
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-48]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	lea rax, [rbp-24]
	push rax
	lea rax, [rbp-56]
	push rax
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_0043
	push 15
	lea rax, [rbp-24]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0044
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	; define w
	push 16
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-64], rax
	push QWORD [rbp-64]
	pop rax
	add rax, 0
	push rax
	push 1
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-64]
	pop rax
	add rax, 8
	push rax
	push 2
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	push 2
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-64]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0045
	push QWORD [rbp-64]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0046
	push QWORD [rbp-64]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	push 3
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	push 5
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0047
	push 3
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0048
	push 5
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	; define oof
	lea rax, [rbp-24]
	push rax
	pop rbx
	lea rax, [rbp-88]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 24
	rep movsb
	push STR_0049
	push 3
	lea rax, [rbp-72]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0050
	push 5
	lea rax, [rbp-72]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0051
	push 3
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0052
	push 5
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

test1:
	push rbp
	mov rbp, rsp
	sub rsp, 64
	push STR_0053
	pop rdi
	call println
	; define a
	; define b
	lea rax, [rbp-48]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	lea rax, [rbp-56]
	push rax
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_0054
	push 15
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	; define w
	push 16
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-64], rax
	push QWORD [rbp-64]
	pop rax
	add rax, 0
	push rax
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-64]
	pop rax
	add rax, 8
	push rax
	push 15
	push 16
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-64]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0055
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0056
	push 15
	push 16
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

test2:
	push rbp
	mov rbp, rsp
	sub rsp, 112
	push STR_0057
	pop rdi
	call println
	; define a
	; define b
	; define a2
	; define b2
	lea rax, [rbp-80]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-72]
	push rax
	push 14
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0058
	push 15
	lea rax, [rbp-80]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0059
	push 14
	lea rax, [rbp-72]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	lea rax, [rbp-24]
	push rax
	lea rax, [rbp-80]
	push rax
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_0060
	push 15
	lea rax, [rbp-24]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0061
	push 14
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0062
	lea rax, [rbp-80]
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-24]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0063
	lea rax, [rbp-72]
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

test3:
	push rbp
	mov rbp, rsp
	sub rsp, 80
	push STR_0064
	pop rdi
	call println
	; define a
	lea rax, [rbp-16]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	push 14
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define ptr1
	lea rax, [rbp-16]
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	; define res
	push QWORD [rbp-40]
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-48], rax
	push STR_0065
	push 15
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0066
	push 15
	push QWORD [rbp-48]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	; define ptr2
	lea rax, [rbp-24]
	push rax
	pop rax
	mov QWORD [rbp-56], rax
	; define b
	lea rax, [rbp-80]
	push rax
	push QWORD [rbp-56]
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_0067
	push 15
	lea rax, [rbp-72]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

foo4:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	; define w2
	lea rax, [rbp-16]
	push QWORD [ rax ]
	pop rbx
	lea rax, [rbp-40]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 16
	rep movsb
	lea rax, [rbp-32]
	push rax
	push 3
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-8]
	lea rax, [rbp-32]
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	mov rax, [rbp-16]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	push QWORD [rbp-24]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test4:
	push rbp
	mov rbp, rsp
	sub rsp, 56
	push STR_0068
	pop rdi
	call println
	; define t
	lea rax, [rbp-32]
	push rax
	push 1
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	push 2
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	push 3
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push 16
	pop rdi
	call alloc
	push rax
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	push 14
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define res
	push 1
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	lea rbx, [rbp-56]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	push 2
	pop rdx
	pop rsi
	pop rdi
	call foo4
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	push STR_0069
	push 21
	push QWORD [rbp-40]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

foo5:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	mov [rbp-8], rdi
	mov rax, [rbp-8]
	add rax, 8
	push rax
	push 42
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	mov rax, [rbp-8]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test5:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push STR_0070
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	push 14
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define res
	lea rax, [rbp-16]
	push rax
	pop rax
	lea rbx, [rbp-40]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	pop rdi
	call foo5
	push rax
	pop rax
	mov QWORD [rbp-24], rax
	push STR_0071
	push 42
	push QWORD [rbp-24]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0072
	push 15
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

foo6:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov rax, [rbp-8]
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	mov rax, [rbp-16]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test6:
	push rbp
	mov rbp, rsp
	sub rsp, 72
	push STR_0073
	pop rdi
	call println
	; define w1
	lea rax, [rbp-16]
	push rax
	push 20
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define w2
	lea rax, [rbp-24]
	push rax
	push 22
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define res
	lea rax, [rbp-16]
	push rax
	pop rax
	lea rbx, [rbp-56]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	lea rax, [rbp-32]
	push rax
	pop rax
	lea rbx, [rbp-72]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	pop rsi
	pop rdi
	call foo6
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	push STR_0074
	push 42
	push QWORD [rbp-40]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

foo7:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	; define w
	lea rax, [rbp-40]
	push rax
	push QWORD [rbp-16]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-24]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-40]
	push rax
	pop rax
	mov rbx, [rbp-8]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	mov rax, rbx
	mov rsp, rbp
	pop rbp
	ret

test7:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push STR_0075
	pop rdi
	call println
	; define w
	push 14
	push 15
	lea rdi, [rbp-32]
	pop rdx
	pop rsi
	call foo7
	push rax
	pop rbx
	lea rax, [rbp-16]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 16
	rep movsb
	; define res
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	push STR_0076
	push 29
	push QWORD [rbp-40]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

bar8:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	; define w
	lea rax, [rbp-24]
	push rax
	push 3
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	push 4
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	mov rbx, [rbp-8]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	mov rax, rbx
	mov rsp, rbp
	pop rbp
	ret

foo8:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rbp-8], rdi
	lea rax, [rbp-8]
	push QWORD [rax]
	lea rdi, [rbp-24]
	call bar8
	push rax
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	; define res
	mov rax, [rbp-8]
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	mov rax, [rbp-8]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	mov QWORD [rbp-32], rax
	push QWORD [rbp-32]
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test8:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push STR_0077
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	push 14
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	; define res
	lea rax, [rbp-16]
	push rax
	pop rax
	lea rbx, [rbp-40]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	pop rdi
	call foo8
	push rax
	pop rax
	mov QWORD [rbp-24], rax
	push STR_0078
	push 7
	push QWORD [rbp-24]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0079
	push 29
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

bar9:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	mov [rbp-8], rdi
	push STR_0080
	push 14
	mov rax, [rbp-8]
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0081
	push 69
	mov rax, [rbp-8]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rax, [rbp-8]
	add rax, 0
	push rax
	push 42
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push STR_0082
	push 42
	mov rax, [rbp-8]
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0083
	push 69
	mov rax, [rbp-8]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

foo9:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	push STR_0084
	push 14
	mov rax, [rbp-8]
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0085
	push 15
	mov rax, [rbp-8]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rax, [rbp-8]
	add rax, 8
	push rax
	push 69
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push QWORD [ rax ]
	pop rax
	lea rbx, [rbp-24]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	pop rdi
	call bar9
	push rax
	pop r13
	push STR_0086
	push 14
	mov rax, [rbp-8]
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0087
	push 69
	mov rax, [rbp-8]
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test9:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_0088
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	push 14
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push 15
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	pop rax
	lea rbx, [rbp-32]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push QWORD rbx
	pop rdi
	call foo9
	push rax
	pop r13
	push STR_0089
	push 14
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0090
	push 15
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

test10:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push STR_0091
	pop rdi
	call println
	; define arr
	push 4
	push 16
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-8], rax
	; define w1
	lea rax, [rbp-24]
	push rax
	push 1
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	push 2
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	push QWORD [rbp-8]
	push 1
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	lea rax, [rbp-24]
	push rax
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	; define resw
	push QWORD [rbp-8]
	push 1
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rbx
	lea rax, [rbp-40]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 16
	rep movsb
	push STR_0092
	push 1
	lea rax, [rbp-40]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0093
	push 2
	lea rax, [rbp-32]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

foo11:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	; define w
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-16]
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
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
	lea rax, [rbp-32]
	push rax
	pop rax
	mov rbx, [rbp-8]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	mov rax, rbx
	mov rsp, rbp
	pop rbp
	ret

test11:
	push rbp
	mov rbp, rsp
	sub rsp, 56
	push STR_0094
	pop rdi
	call println
	; define arr
	push 4
	push 16
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-8], rax
	; define i
	push 0
	pop rax
	mov QWORD [rbp-16], rax
whc_0095:
	push QWORD [rbp-16]
	push 100
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je whe_0096
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	push QWORD [rbp-16]
	lea rdi, [rbp-32]
	pop rsi
	call foo11
	push rax
	pop rax ;src
	pop rbx ;dst
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
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
	jmp whc_0095
whe_0096:
	; define n
	push 42
	pop rax
	mov QWORD [rbp-40], rax
	; define resw
	push QWORD [rbp-8]
	push QWORD [rbp-40]
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rbx
	lea rax, [rbp-56]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 16
	rep movsb
	push STR_0097
	push QWORD [rbp-40]
	lea rax, [rbp-56]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0098
	push QWORD [rbp-40]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	lea rax, [rbp-48]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	mov rsp, rbp
	pop rbp
	ret

bar12:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	; define w
	lea rax, [rbp-24]
	push rax
	push 1
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	push 2
	pop rax ;src
	pop rbx ;dst
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	mov rbx, [rbp-8]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	mov rax, rbx
	mov rsp, rbp
	pop rbp
	ret

foo12:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	lea rdi, [rbp-24]
	call bar12
	push rax
	pop rax
	mov rbx, [rbp-8]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	mov rax, rbx
	mov rsp, rbp
	pop rbp
	ret

test12:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_0099
	pop rdi
	call println
	; define res
	lea rdi, [rbp-32]
	call foo12
	push rax
	pop rbx
	lea rax, [rbp-16]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 16
	rep movsb
	push STR_0100
	push 1
	lea rax, [rbp-16]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_0101
	push 2
	lea rax, [rbp-8]
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
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
	call test4
	call test5
	call test6
	call test7
	call test8
	call test9
	call test10
	call test11
	call test12
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
	STR_0037: db "=====test0=====", 0
	STR_0038: db "0xcafebabe1", 0
	STR_0039: db "0xcafebabe2", 0
	STR_0040: db "0xcafebabe3", 0
	STR_0041: db "0x00f", 0
	STR_0042: db "0xf00", 0
	STR_0043: db "0x00f", 0
	STR_0044: db "0xf00", 0
	STR_0045: db "0x101", 0
	STR_0046: db "0x202", 0
	STR_0047: db "0x3", 0
	STR_0048: db "0x5", 0
	STR_0049: db "0x3", 0
	STR_0050: db "0x5", 0
	STR_0051: db "0x3", 0
	STR_0052: db "0x5", 0
	STR_0053: db "=====test1=====", 0
	STR_0054: db "0x0000f", 0
	STR_0055: db "0x00f00", 0
	STR_0056: db "0xf0000", 0
	STR_0057: db "=====test2=====", 0
	STR_0058: db "0xf", 0
	STR_0059: db "0xe", 0
	STR_0060: db "0xf", 0
	STR_0061: db "0xe", 0
	STR_0062: db "0xf", 0
	STR_0063: db "0xe", 0
	STR_0064: db "=====test3=====", 0
	STR_0065: db "0xf", 0
	STR_0066: db "0xf", 0
	STR_0067: db "0xf", 0
	STR_0068: db "=====test4=====", 0
	STR_0069: db "0x15", 0
	STR_0070: db "=====test5=====", 0
	STR_0071: db "0x2a", 0
	STR_0072: db "0x0f", 0
	STR_0073: db "=====test6=====", 0
	STR_0074: db "0x2a", 0
	STR_0075: db "=====test7=====", 0
	STR_0076: db "0x1d", 0
	STR_0077: db "=====test8=====", 0
	STR_0078: db "0x7", 0
	STR_0079: db "0x1d", 0
	STR_0080: db "0x0e", 0
	STR_0081: db "0x45", 0
	STR_0082: db "0x2a", 0
	STR_0083: db "0x45", 0
	STR_0084: db "0x0e", 0
	STR_0085: db "0x0f", 0
	STR_0086: db "0x0e", 0
	STR_0087: db "0x45", 0
	STR_0088: db "=====test9=====", 0
	STR_0089: db "0x0e", 0
	STR_0090: db "0x0f", 0
	STR_0091: db "=====test10=====", 0
	STR_0092: db "0x1", 0
	STR_0093: db "0x2", 0
	STR_0094: db "=====test11=====", 0
	STR_0097: db "0x2a", 0
	STR_0098: db "0x2b", 0
	STR_0099: db "=====test12=====", 0
	STR_0100: db "0x1", 0
	STR_0101: db "0x2", 0

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
