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
	push QWORD [GLBL_SYS_WRITE]
	push QWORD [GLBL_STDOUT]
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	pop rdx
	pop rsi
	pop rdi
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
	push QWORD [GLBL_SYS_EXIT]
	push QWORD [rbp-8]
	pop rdi
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
	push QWORD [GLBL_SYS_MUNMAP]
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	pop rsi
	pop rdi
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
	push QWORD [GLBL_SYS_MMAP]
	push QWORD [rbp-32]
	push QWORD [rbp-8]
	push QWORD [GLBL_PROT_READ]
	push QWORD [GLBL_PROT_WRITE]
	pop rbx
	pop rax
	or rax, rbx
	push rax
	push QWORD [GLBL_MAP_PRIVATE]
	push QWORD [GLBL_MAP_ANONYMOUS]
	pop rbx
	pop rax
	or rax, rbx
	push rax
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop r9
	pop r8
	pop r10
	pop rdx
	pop rsi
	pop rdi
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
	sub rsp, 48
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
	; define i
	push 0
	pop rax
	mov QWORD [rbp-48], rax
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
	push QWORD [rbp-48]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push QWORD [rbp-8]
	push QWORD [rbp-48]
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
	push QWORD [GLBL_SYS_OPEN]
	push QWORD [rbp-8]
	push 0
	push 0
	pop rdx
	pop rsi
	pop rdi
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
	push QWORD [GLBL_SYS_READ]
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rdx
	pop rsi
	pop rdi
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
	pop rax
	test rax, rax
	jnz BOOL_14
	push 0
	jmp BOOL_15
BOOL_14:
	push QWORD [rbp-40]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
BOOL_15:
	pop ax
	cmp al, 0
	je IF_16
	push STR_17
	pop rdi
	call println
	push 1
	pop rdi
	call exit
IF_16:
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
	je IF_18
	push STR_19
	pop rdi
	call println
IF_18:
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
	je IF_20
	push STR_21
	pop rdi
	call println
	jmp WHE_13
IF_20:
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

fmt_dec:
	push rbp
	mov rbp, rsp
	sub rsp, 56
	mov [rbp-8], rdi
	; define out
	push 20
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	; define idx
	push 0
	pop rax
	mov QWORD [rbp-24], rax
	push QWORD [rbp-8]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop ax
	cmp al, 0
	je IF_22
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 45
	pop rax
	pop rbx
	mov BYTE [rbx], al
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	pop rax
	neg rax
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	push QWORD [rbp-24]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
IF_22:
	; define start
	push QWORD [rbp-24]
	pop rax
	mov QWORD [rbp-32], rax
	push QWORD [rbp-8]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
WHC_23:
	push QWORD [rbp-8]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setne cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_24
	push QWORD [rbp-8]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
	; define mod
	push QWORD [rbp-8]
	push 10
	pop rbx
	pop rax
	cqo
	idiv rbx
	push rdx
	pop rax
	mov QWORD [rbp-40], rax
	push STR_25
	push QWORD [rbp-40]
	pop rdi
	call fmt_hex
	push rax
	pop rsi
	pop rdi
	call strcat
	push rax
	pop rdi
	call println
	push QWORD [rbp-40]
	push 0
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_26
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 48
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_26:
	push QWORD [rbp-40]
	push 1
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_27
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 49
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_27:
	push QWORD [rbp-40]
	push 2
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_28
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 50
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_28:
	push QWORD [rbp-40]
	push 3
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_29
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 51
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_29:
	push QWORD [rbp-40]
	push 4
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_30
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 52
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_30:
	push QWORD [rbp-40]
	push 5
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_31
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 53
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_31:
	push QWORD [rbp-40]
	push 6
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_32
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 54
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_32:
	push QWORD [rbp-40]
	push 7
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_33
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 55
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_33:
	push QWORD [rbp-40]
	push 8
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_34
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 56
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_34:
	push QWORD [rbp-40]
	push 9
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	sete cl
	push rcx
	pop ax
	cmp al, 0
	je IF_35
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 57
	pop rax
	pop rbx
	mov BYTE [rbx], al
IF_35:
	lea rax, [rbp-24]
	push rax
	push QWORD [rbp-24]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 10
	pop rbx
	pop rax
	cqo
	idiv rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_23
WHE_24:
	; define end
	push QWORD [rbp-24]
	pop rax
	mov QWORD [rbp-48], rax
	push QWORD [rbp-32]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
	push QWORD [rbp-48]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
WHC_36:
	push QWORD [rbp-32]
	push QWORD [rbp-48]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_37
	push QWORD [rbp-32]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
	push QWORD [rbp-48]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
	; define aux
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-56], rax
	push QWORD [rbp-16]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push QWORD [rbp-16]
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
	push QWORD [rbp-16]
	push QWORD [rbp-48]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push QWORD [rbp-56]
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
	lea rax, [rbp-48]
	push rax
	push QWORD [rbp-48]
	push 1
	pop rbx
	pop rax
	sub rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_36
WHE_37:
	push QWORD [rbp-16]
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
	push STR_38
	pop rax
	mov QWORD [rbp-24], rax
	push QWORD [rbp-16]
	push 0
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 48
	pop rax
	pop rbx
	mov BYTE [rbx], al
	push QWORD [rbp-16]
	push 1
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
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
WHC_39:
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
	je WHE_40
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
	jmp WHC_39
WHE_40:
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
WHC_41:
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
	je WHE_42
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
	jmp WHC_41
WHE_42:
	lea rax, [rbp-56]
	push rax
	push 0
	pop rax
	pop rbx
	mov [rbx], rax
WHC_43:
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
	je WHE_44
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
	jmp WHC_43
WHE_44:
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
WHC_45:
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
	je WHE_46
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
	pop rax
	test rax, rax
	jz BOOL_47
	push 1
	jmp BOOL_48
BOOL_47:
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
BOOL_48:
	pop ax
	cmp al, 0
	je IF_49
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_49:
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
	je IF_50
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_50:
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
	jmp WHC_45
WHE_46:
	push 1
	pop rax
	mov rsp, rbp
	pop rbp
	ret

rev_str:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	; define str
	push 17
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-8], rax
	; define base
	push STR_51
	pop rax
	mov QWORD [rbp-16], rax
	; define i
	push 0
	pop rax
	mov QWORD [rbp-24], rax
WHC_52:
	push QWORD [rbp-24]
	push 16
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_53
	push QWORD [rbp-8]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push QWORD [rbp-16]
	push QWORD [rbp-24]
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
	lea rax, [rbp-24]
	push rax
	push QWORD [rbp-24]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_52
WHE_53:
	push QWORD [rbp-8]
	pop rdi
	call println
	; define start
	push 0
	pop rax
	mov QWORD [rbp-32], rax
	; define end
	push 16
	push 1
	pop rbx
	pop rax
	sub rax, rbx
	push rax
	pop rax
	mov QWORD [rbp-40], rax
WHC_54:
	push QWORD [rbp-32]
	push QWORD [rbp-40]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_55
	; define aux
	push QWORD [rbp-8]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-48], rax
	push QWORD [rbp-8]
	push QWORD [rbp-32]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push QWORD [rbp-8]
	push QWORD [rbp-40]
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
	push QWORD [rbp-8]
	push QWORD [rbp-40]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push QWORD [rbp-48]
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
	lea rax, [rbp-40]
	push rax
	push QWORD [rbp-40]
	push 1
	pop rbx
	pop rax
	sub rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_54
WHE_55:
	push QWORD [rbp-8]
	pop rdi
	call println
	mov rsp, rbp
	pop rbp
	ret

fooarrarr:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	mov [rbp-8], rdi
	; define str
	push QWORD [rbp-8]
	push 1
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-16]
	pop rdi
	call println
	push QWORD [rbp-8]
	push 0
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rdi
	call println
	push QWORD [rbp-8]
	push 1
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rdi
	call println
	push QWORD [rbp-8]
	push 2
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rdi
	call println
	push QWORD [rbp-8]
	push 3
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rdi
	call println
	mov rsp, rbp
	pop rbp
	ret

arrarr:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	; define arr
	push 4
	push 8
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-8], rax
	push QWORD [rbp-8]
	push 0
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push STR_56
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	push 1
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push STR_57
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	push 2
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push STR_58
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	push 3
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push STR_59
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	pop rdi
	call fooarrarr
	mov rsp, rbp
	pop rbp
	ret

main:
	push rbp
	mov rbp, rsp
	sub rsp, 0
	call rev_str
	call arrarr
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
	STR_17: db "No bytes read :(", 0
	STR_19: db "there is more to read...", 0
	STR_21: db "there is NO more to read!", 0
	STR_25: db "mod: ", 0
	STR_38: db "0123456789abcdef", 0
	STR_51: db "0123456789abcdef", 0
	STR_56: db "hello0", 0
	STR_57: db "hello1", 0
	STR_58: db "hello2", 0
	STR_59: db "hello3", 0
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
