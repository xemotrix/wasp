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
	pop rax
	test rax, rax
	jz BOOL_29
	push 1
	jmp BOOL_30
BOOL_29:
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
BOOL_30:
	pop ax
	cmp al, 0
	je IF_31
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_31:
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
	je IF_32
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret
IF_32:
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
	je IF_33
	push STR_34
	pop rdi
	call print
	push QWORD [rbp-8]
	pop rdi
	call print
	push STR_35
	pop rdi
	call print
	push QWORD [rbp-24]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
IF_33:
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
	je IF_36
	push STR_37
	pop rdi
	call print
	push QWORD [rbp-16]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call print
	push STR_38
	pop rdi
	call print
	push QWORD [rbp-24]
	pop rdi
	call fmt_hex
	push rax
	pop rdi
	call println
IF_36:
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test0:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push STR_39
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
WHC_40:
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
	je WHE_41
	lea rax, [rbp-16]
	push rax
	push QWORD [rbp-16]
	push QWORD [rbp-8]
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
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_40
WHE_41:
	push STR_42
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
	push STR_43
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
WHC_44:
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
	je WHE_45
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
	je IF_46
	jmp WHE_45
IF_46:
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	jmp WHC_44
WHE_45:
	push STR_47
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
	push STR_48
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
WHC_49:
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
	je WHE_50
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
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
	je IF_51
	jmp WHC_49
IF_51:
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
	je IF_52
	push STR_53
	pop rdi
	call println
	push 1
	pop rdi
	call exit
IF_52:
	jmp WHC_49
WHE_50:
	push STR_54
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
	push STR_55
	pop rdi
	call println
	; define i
	push 0
	pop rax
	mov QWORD [rbp-8], rax
WHC_56:
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
	je WHE_57
	lea rax, [rbp-8]
	push rax
	push QWORD [rbp-8]
	push 1
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	; define j
	push 42
	pop rax
	mov QWORD [rbp-16], rax
	jmp WHC_56
WHE_57:
	push STR_58
	push 100
	push QWORD [rbp-8]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_59
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
	STR_34: db "OK: expected: (", 0
	STR_35: db "), got: ", 0
	STR_37: db "FAIL: expected ", 0
	STR_38: db " but got ", 0
	STR_39: db "====test0====", 0
	STR_42: db "0x1356", 0
	STR_43: db "====test1====", 0
	STR_47: db "0x2a", 0
	STR_48: db "====test2====", 0
	STR_53: db "failed!", 0
	STR_54: db "0x64", 0
	STR_55: db "====test3====", 0
	STR_58: db "0x64", 0
	STR_59: db "0x2a", 0
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
