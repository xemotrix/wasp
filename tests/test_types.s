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
WHC_1:
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
	je WHE_2
	lea rax, [rbp-16]
	push rax
	push QWORD [rbp-16]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_1
WHE_2:
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
	push STR_3
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
WHC_4:
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
	je WHE_5
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
	je IF_6
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_6:
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_4
WHE_5:
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
	pop rax
	pop rbx
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
	push 1
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
	je IF_7
	push QWORD [rbp-8]
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_7:
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
WHC_8:
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
	je WHE_9
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
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-40]
	push rax
	push QWORD [rbp-40]
	push 8
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_8
WHE_9:
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
	je IF_10
	push STR_11
	pop rdi
	call println
	push 1
	pop rdi
	call exit
IF_10:
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
WHC_12:
	push 1
	pop rax
	cmp rax, 0
	je WHE_13
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
	je IF_14
	push STR_15
	pop rdi
	call println
	push 1
	pop rdi
	call exit
IF_14:
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
	je IF_16
	push STR_17
	pop rdi
	call println
IF_16:
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
	je IF_18
	push STR_19
	pop rdi
	call println
	jmp WHE_13
IF_18:
	lea rax, [rbp-40]
	push rax
	push QWORD [rbp-40]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_12
WHE_13:
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
	push STR_20
	pop rax
	mov QWORD [rbp-24], rax
	push QWORD [rbp-16]
	push 48
	pop rax
	pop rbx
	mov BYTE [rbx], al
	push QWORD [rbp-16]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	push 120
	pop rax
	pop rbx
	mov BYTE [rbx], al
	; define i
	push 0
	pop rax
	mov QWORD [rbp-32], rax
	; define shift
	; define idx
WHC_21:
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
	je WHE_22
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
	pop rax
	pop rbx
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
	pop rax
	pop rbx
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
	pop rax
	pop rbx
	mov BYTE [rbx], al
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_21
WHE_22:
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
	pop rax
	pop rbx
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
WHC_23:
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
	je WHE_24
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
	pop rax
	pop rbx
	mov BYTE [rbx], al
	lea rax, [rbp-48]
	push rax
	push QWORD [rbp-48]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-56]
	push rax
	push QWORD [rbp-56]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_23
WHE_24:
	lea rax, [rbp-56]
	push rax
	push 0
	pop rax
	pop rbx
	mov [rbx], rax
WHC_25:
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
	je WHE_26
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
	pop rax
	pop rbx
	mov BYTE [rbx], al
	lea rax, [rbp-48]
	push rax
	push QWORD [rbp-48]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-56]
	push rax
	push QWORD [rbp-56]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_25
WHE_26:
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
WHC_27:
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
	je WHE_28
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
	je IF_29
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_29:
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
	je IF_30
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_30:
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_27
WHE_28:
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
	je IF_31
	push STR_32
	pop rdi
	call print
	push QWORD [rbp-8]
	pop rdi
	call print
	push STR_33
	pop rdi
	call print
	push QWORD [rbp-24]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
IF_31:
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
	je IF_34
	push STR_35
	pop rdi
	call print
	push QWORD [rbp-16]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call print
	push STR_36
	pop rdi
	call print
	push QWORD [rbp-24]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
IF_34:
	mov rsp, rbp
	pop rbp
	ret

test0:
	push rbp
	mov rbp, rsp
	sub rsp, 88
	push STR_37
	pop rdi
	call println
	; define i
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 0
	push rax
	mov rax, 54491065313
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	mov rax, 54491065314
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	mov rax, 54491065315
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_38
	mov rax, 54491065313
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_39
	mov rax, 54491065314
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_40
	mov rax, 54491065315
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
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
	pop rax
	add rax, 0
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-56]
	push rax
	pop rax
	add rax, 8
	push rax
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_41
	push 15
	lea rax, [rbp-56]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_42
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-56]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	lea rax, [rbp-56]
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_43
	push 15
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_44
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
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
	pop rax
	pop rbx
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
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	push QWORD [rbp-64]
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_45
	push QWORD [rbp-64]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_46
	push QWORD [rbp-64]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	push 3
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	push 5
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_47
	push 3
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_48
	push 5
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rbx
	lea rax, [rbp-88]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 24
	rep movsb
	push STR_49
	push 3
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 16
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
	push STR_50
	push 5
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 16
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
	push STR_51
	push 3
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_52
	push 5
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_53
	pop rdi
	call println
	; define a
	; define b
	lea rax, [rbp-56]
	push rax
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	lea rax, [rbp-56]
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_54
	push 15
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
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
	pop rax
	pop rbx
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
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	push QWORD [rbp-64]
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_55
	push 15
	push 8
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_56
	push 15
	push 16
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
	push rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_57
	pop rdi
	call println
	; define a
	; define b
	; define a2
	; define b2
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_58
	push 15
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_59
	push 14
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_60
	push 15
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_61
	push 14
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_62
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_63
	lea rax, [rbp-88]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
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

test3:
	push rbp
	mov rbp, rsp
	sub rsp, 80
	push STR_64
	pop rdi
	call println
	; define a
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	; define ptr1
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	; define res
	push QWORD [rbp-40]
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-48], rax
	push STR_65
	push 15
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_66
	push 15
	push QWORD [rbp-48]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	; define ptr2
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	mov QWORD [rbp-56], rax
	; define b
	lea rax, [rbp-80]
	push rax
	push QWORD [rbp-56]
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 24
	rep movsb
	push STR_67
	push 15
	lea rax, [rbp-80]
	push rax
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

foo4:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	mov [rbp-24], rdx
	; define w2
	lea rax, [rbp-16]
	push QWORD [rax]
	pop rbx
	lea rax, [rbp-40]
	mov rsi, rbx
	mov rdi, rax
	mov rcx, 16
	rep movsb
	lea rax, [rbp-40]
	push rax
	pop rax
	add rax, 8
	push rax
	push 3
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	lea rax, [rbp-40]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	lea rax, [rbp-16]
	push QWORD [rax]
	pop rax
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
	push STR_68
	pop rdi
	call println
	; define t
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 0
	push rax
	push 1
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
	push rax
	push 2
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	push 3
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	push 16
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
	push rax
	pop rax
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	; define res
	push 1
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 16
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
	push STR_69
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
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	push 42
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
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
	push STR_70
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax
	pop rbx
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
	push STR_71
	push 42
	push QWORD [rbp-24]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_72
	push 15
	lea rax, [rbp-16]
	push rax
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

foo6:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-16]
	push QWORD [rax]
	pop rax
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
	push STR_73
	pop rdi
	call println
	; define w1
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	push 20
	pop rax
	pop rbx
	mov [rbx], rax
	; define w2
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	push 22
	pop rax
	pop rbx
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
	push STR_74
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
	pop rax
	add rax, 0
	push rax
	push QWORD [rbp-16]
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-40]
	push rax
	pop rax
	add rax, 8
	push rax
	push QWORD [rbp-24]
	pop rax
	pop rbx
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
	push STR_75
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
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	push STR_76
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
	pop rax
	add rax, 0
	push rax
	push 3
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	push 4
	pop rax
	pop rbx
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
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	; define res
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
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
	push STR_77
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax
	pop rbx
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
	push STR_78
	push 7
	push QWORD [rbp-24]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_79
	push 29
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 8
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
	push STR_80
	push 14
	lea rax, [rbp-8]
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
	push STR_81
	push 69
	lea rax, [rbp-8]
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
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	push 42
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_82
	push 42
	lea rax, [rbp-8]
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
	push STR_83
	push 69
	lea rax, [rbp-8]
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
	push STR_84
	push 14
	lea rax, [rbp-8]
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
	push STR_85
	push 15
	lea rax, [rbp-8]
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
	push QWORD [rax]
	pop rax
	add rax, 8
	push rax
	push 69
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-8]
	push QWORD [rax]
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
	push STR_86
	push 14
	lea rax, [rbp-8]
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
	push STR_87
	push 69
	lea rax, [rbp-8]
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
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test9:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_88
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 8
	push rax
	push 15
	pop rax
	pop rbx
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
	push STR_89
	push 14
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_90
	push 15
	lea rax, [rbp-16]
	push rax
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

test10:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push STR_91
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
	pop rax
	add rax, 0
	push rax
	push 1
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	push 2
	pop rax
	pop rbx
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
	pop rax
	pop rbx
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
	push STR_92
	push 1
	lea rax, [rbp-40]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_93
	push 2
	lea rax, [rbp-40]
	push rax
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

foo11:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	; define w
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 0
	push rax
	push QWORD [rbp-16]
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 8
	push rax
	push QWORD [rbp-16]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
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
	push STR_94
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
WHC_95:
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
	je WHE_96
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
	pop rax
	pop rbx
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
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_95
WHE_96:
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
	push STR_97
	push QWORD [rbp-40]
	lea rax, [rbp-56]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_98
	push QWORD [rbp-40]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	lea rax, [rbp-56]
	push rax
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

bar12:
	push rbp
	mov rbp, rsp
	sub rsp, 24
	mov [rbp-8], rdi
	; define w
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 0
	push rax
	push 1
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	push 2
	pop rax
	pop rbx
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
	push STR_99
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
	push STR_100
	push 1
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_101
	push 2
	lea rax, [rbp-16]
	push rax
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

test13:
	push rbp
	mov rbp, rsp
	sub rsp, 0
	push STR_102
	pop rdi
	call println
	push QWORD GLBL_XD
	push 16
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_XD]
	pop rax
	add rax, 0
	push rax
	push 12
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_XD]
	pop rax
	add rax, 8
	push rax
	push 13
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_103
	push 12
	push QWORD [GLBL_XD]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_104
	push 13
	push QWORD [GLBL_XD]
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

test14:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push STR_105
	pop rdi
	call println
	push QWORD GLBL_WARR
	push 24
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_WARR]
	pop rax
	add rax, 8
	push rax
	push 1
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_WARR]
	pop rax
	add rax, 16
	push rax
	push 2
	pop rax
	pop rbx
	mov [rbx], rax
	; define some_ptr
	push 400
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-8], rax
	push QWORD [GLBL_WARR]
	pop rax
	add rax, 0
	push rax
	push QWORD [rbp-8]
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_106
	push QWORD [rbp-8]
	push QWORD [GLBL_WARR]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_107
	push 1
	push QWORD [GLBL_WARR]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_108
	push 2
	push QWORD [GLBL_WARR]
	pop rax
	add rax, 16
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

test15:
	push rbp
	mov rbp, rsp
	sub rsp, 0
	push STR_109
	pop rdi
	call println
	push QWORD GLBL_W1
	push 24
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_W1]
	pop rax
	add rax, 0
	push rax
	push 1
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_W1]
	pop rax
	add rax, 8
	push rax
	push 2
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD GLBL_W2
	push 24
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_W2]
	pop rax
	add rax, 0
	push rax
	push 3
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [GLBL_W2]
	pop rax
	add rax, 8
	push rax
	push 4
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_110
	push 1
	push QWORD [GLBL_W1]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_111
	push 2
	push QWORD [GLBL_W1]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_112
	push 3
	push QWORD [GLBL_W2]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_113
	push 4
	push QWORD [GLBL_W2]
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

foo16:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	mov [rbp-8], rdi
	push QWORD [rbp-8]
	pop rax
	add rax, 0
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	mov rsp, rbp
	pop rbp
	ret

bar16:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	; define xd
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-16]
	pop rdi
	call foo16
	lea rax, [rbp-8]
	push QWORD [rax]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop r13
	push STR_114
	push 15
	lea rax, [rbp-8]
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
	push STR_115
	push 2
	lea rax, [rbp-8]
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

test16:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_116
	pop rdi
	call println
	; define w
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	push 1
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 8
	push rax
	push 2
	pop rax
	pop rbx
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
	call bar16
	push STR_117
	push 1
	lea rax, [rbp-16]
	push rax
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push STR_118
	push 2
	lea rax, [rbp-16]
	push rax
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
	call test13
	call test14
	call test15
	call test16
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

_start:
	mov rdi, [rsp]
	lea rsi, [rsp+8]
	call main
	mov rdi, rax
	mov rax, 60
	syscall

section .rodata
	STR_3: db "", 10, "", 0
	STR_11: db "Error reading file", 0
	STR_15: db "No bytes read :(", 0
	STR_17: db "there is more to read...", 0
	STR_19: db "there is NO more to read!", 0
	STR_20: db "0123456789abcdef", 0
	STR_32: db "OK: expected: (", 0
	STR_33: db "), got: ", 0
	STR_35: db "FAIL: expected ", 0
	STR_36: db " but got ", 0
	STR_37: db "=====test0=====", 0
	STR_38: db "0xcafebabe1", 0
	STR_39: db "0xcafebabe2", 0
	STR_40: db "0xcafebabe3", 0
	STR_41: db "0x00f", 0
	STR_42: db "0xf00", 0
	STR_43: db "0x00f", 0
	STR_44: db "0xf00", 0
	STR_45: db "0x101", 0
	STR_46: db "0x202", 0
	STR_47: db "0x3", 0
	STR_48: db "0x5", 0
	STR_49: db "0x3", 0
	STR_50: db "0x5", 0
	STR_51: db "0x3", 0
	STR_52: db "0x5", 0
	STR_53: db "=====test1=====", 0
	STR_54: db "0x0000f", 0
	STR_55: db "0x00f00", 0
	STR_56: db "0xf0000", 0
	STR_57: db "=====test2=====", 0
	STR_58: db "0xf", 0
	STR_59: db "0xe", 0
	STR_60: db "0xf", 0
	STR_61: db "0xe", 0
	STR_62: db "0xf", 0
	STR_63: db "0xe", 0
	STR_64: db "=====test3=====", 0
	STR_65: db "0xf", 0
	STR_66: db "0xf", 0
	STR_67: db "0xf", 0
	STR_68: db "=====test4=====", 0
	STR_69: db "0x15", 0
	STR_70: db "=====test5=====", 0
	STR_71: db "0x2a", 0
	STR_72: db "0x0f", 0
	STR_73: db "=====test6=====", 0
	STR_74: db "0x2a", 0
	STR_75: db "=====test7=====", 0
	STR_76: db "0x1d", 0
	STR_77: db "=====test8=====", 0
	STR_78: db "0x7", 0
	STR_79: db "0x1d", 0
	STR_80: db "0x0e", 0
	STR_81: db "0x45", 0
	STR_82: db "0x2a", 0
	STR_83: db "0x45", 0
	STR_84: db "0x0e", 0
	STR_85: db "0x0f", 0
	STR_86: db "0x0e", 0
	STR_87: db "0x45", 0
	STR_88: db "=====test9=====", 0
	STR_89: db "0x0e", 0
	STR_90: db "0x0f", 0
	STR_91: db "=====test10=====", 0
	STR_92: db "0x1", 0
	STR_93: db "0x2", 0
	STR_94: db "=====test11=====", 0
	STR_97: db "0x2a", 0
	STR_98: db "0x2b", 0
	STR_99: db "=====test12=====", 0
	STR_100: db "0x1", 0
	STR_101: db "0x2", 0
	STR_102: db "=====test13=====", 0
	STR_103: db "0xc", 0
	STR_104: db "0xd", 0
	STR_105: db "=====test14=====", 0
	STR_106: db "some ptr", 0
	STR_107: db "0x1", 0
	STR_108: db "0x2", 0
	STR_109: db "=====test15=====", 0
	STR_110: db "0x1", 0
	STR_111: db "0x2", 0
	STR_112: db "0x3", 0
	STR_113: db "0x4", 0
	STR_114: db "0xf", 0
	STR_115: db "0x2", 0
	STR_116: db "=====test16=====", 0
	STR_117: db "0xf", 0
	STR_118: db "0x2", 0
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

section .data
	GLBL_XD: dq 0
	GLBL_WARR: dq 0
	GLBL_OOPS: dq 0
	GLBL_W1: dq 0
	GLBL_W2: dq 0
