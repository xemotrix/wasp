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
	sub rsp, 32
	push STR_39
	pop rdi
	call println
	; define num
	push 42
	pop rax
	mov QWORD [rbp-8], rax
	; define arr
	push 8
	push QWORD [rbp-8]
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	; define i
	push 0
	pop rax
	mov QWORD [rbp-24], rax
WHC_40:
	push QWORD [rbp-24]
	push QWORD [rbp-8]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_41
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push 1
	push QWORD [rbp-24]
	pop rbx
	pop rax
	mov rcx, rbx
	shl rax, cl
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
	jmp WHC_40
WHE_41:
	; define accum
	push 0
	pop rax
	mov QWORD [rbp-32], rax
	lea rax, [rbp-24]
	push rax
	push 0
	pop rax
	pop rbx
	mov [rbx], rax
WHC_42:
	push QWORD [rbp-24]
	push QWORD [rbp-8]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_43
	lea rax, [rbp-32]
	push rax
	push QWORD [rbp-32]
	push QWORD [rbp-16]
	push QWORD [rbp-24]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rbx
	pop rax
	add rax, rbx
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
	jmp WHC_42
WHE_43:
	push STR_44
	mov rax, 4398046511103
	push rax
	push QWORD [rbp-32]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push 0
	pop rax
	mov rsp, rbp
	pop rbp
	ret

test1:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_45
	pop rdi
	call println
	; define num
	push 10
	pop rax
	mov QWORD [rbp-8], rax
	; define arr
	push 16
	push QWORD [rbp-8]
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	; define t
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 0
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
	push 14
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-16]
	push 3
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	lea rax, [rbp-32]
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 16
	rep movsb
	push STR_46
	push 15
	push QWORD [rbp-16]
	push 3
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_47
	push 14
	push QWORD [rbp-16]
	push 3
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rax
	add rax, 8
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

test2:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push STR_48
	pop rdi
	call println
	; define num
	push 10
	pop rax
	mov QWORD [rbp-8], rax
	; define arr
	push 16
	push QWORD [rbp-8]
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-16]
	push 4
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rax
	add rax, 0
	push rax
	push 15
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_49
	push 15
	push QWORD [rbp-16]
	push 4
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rax
	add rax, 0
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

test3:
	push rbp
	mov rbp, rsp
	sub rsp, 40
	push STR_50
	pop rdi
	call println
	; define num
	push 10
	pop rax
	mov QWORD [rbp-8], rax
	; define arr
	push QWORD [rbp-8]
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-16], rax
	; define source
	push STR_51
	pop rax
	mov QWORD [rbp-24], rax
	; define len
	push QWORD [rbp-24]
	pop rdi
	call strlen
	push rax
	pop rax
	mov QWORD [rbp-32], rax
	; define i
	push 0
	pop rax
	mov QWORD [rbp-40], rax
WHC_52:
	push QWORD [rbp-40]
	push QWORD [rbp-32]
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_53
	push QWORD [rbp-16]
	push QWORD [rbp-40]
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push QWORD [rbp-24]
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
	jmp WHC_52
WHE_53:
	push QWORD [rbp-16]
	push 24
	pop rax
	pop rbx
	imul rax, 1
	add rbx, rax
	push rbx
	push 35
	pop rax
	pop rbx
	mov BYTE [rbx], al
	push QWORD [rbp-16]
	pop rdi
	call println
	mov rsp, rbp
	pop rbp
	ret

test4:
	push rbp
	mov rbp, rsp
	sub rsp, 16
	push STR_54
	pop rdi
	call println
	; define aptr
	push 16
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-8], rax
	; define num
	push 30
	pop rax
	mov QWORD [rbp-16], rax
	push QWORD [rbp-8]
	pop rax
	add rax, 0
	push rax
	push 8
	push QWORD [rbp-16]
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	pop rax
	add rax, 8
	push rax
	push 16
	push QWORD [rbp-16]
	pop rbx
	pop rax
	imul rax, rbx
	push rax
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	push QWORD [rbp-8]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	push 13
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push 42
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_55
	push 42
	push QWORD [rbp-8]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	push 13
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push QWORD [rbp-8]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 14
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rax
	add rax, 1
	push rax
	push 42
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_56
	push 42
	push QWORD [rbp-8]
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 14
	pop rax
	pop rbx
	imul rax, 16
	add rbx, rax
	push rbx
	pop rax
	add rax, 1
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

test5:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_57
	pop rdi
	call println
	; define arr
	push 8
	push 10
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
WHC_58:
	push QWORD [rbp-16]
	push 10
	pop rbx
	pop rax
	xor rcx, rcx
	cmp rax, rbx
	setl cl
	push rcx
	pop rax
	cmp rax, 0
	je WHE_59
	push QWORD [rbp-8]
	push QWORD [rbp-16]
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	push QWORD [rbp-16]
	pop rax
	pop rbx
	mov [rbx], rax
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
	jmp WHC_58
WHE_59:
	; define ref
	push QWORD [rbp-8]
	push 7
	pop rax
	pop rbx
	imul rax, 8
	add rbx, rax
	push rbx
	pop rax
	mov QWORD [rbp-24], rax
	; define res
	push QWORD [rbp-24]
	pop rax
	push QWORD [rax]
	pop rax
	mov QWORD [rbp-32], rax
	push STR_60
	push 7
	push QWORD [rbp-32]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	mov rsp, rbp
	pop rbp
	ret

test6:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	push STR_61
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
	add rax, 24
	push rax
	push 4
	pop rax
	pop rbx
	mov [rbx], rax
	; define h
	push 5000
	pop rdi
	call alloc
	push rax
	pop rax
	mov QWORD [rbp-40], rax
	push QWORD [rbp-40]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	lea rax, [rbp-32]
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 32
	rep movsb
	push STR_62
	push 1
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
	push rax
	pop r13
	push STR_63
	push 2
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
	push rax
	pop r13
	push STR_64
	push 3
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
	push rax
	pop r13
	push STR_65
	push 4
	lea rax, [rbp-32]
	push rax
	pop rax
	add rax, 24
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	; define tp
	push QWORD [rbp-40]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	mov QWORD [rbp-48], rax
	push STR_66
	push 1
	push QWORD [rbp-48]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_67
	push 2
	push QWORD [rbp-48]
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
	push rax
	pop r13
	push STR_68
	push 3
	push QWORD [rbp-48]
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
	push rax
	pop r13
	push STR_69
	push 4
	push QWORD [rbp-48]
	pop rax
	add rax, 24
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

test7:
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push STR_70
	pop rdi
	call println
	; define h
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	push 5000
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 24
	push rax
	push 4
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_71
	push 1
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_72
	push 2
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	push rax
	pop r13
	push STR_73
	push 3
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	push rax
	pop r13
	push STR_74
	push 4
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 24
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	; define tp
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	mov QWORD [rbp-32], rax
	push STR_75
	push 1
	push QWORD [rbp-32]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_76
	push 2
	push QWORD [rbp-32]
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
	push rax
	pop r13
	push STR_77
	push 3
	push QWORD [rbp-32]
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
	push rax
	pop r13
	push STR_78
	push 4
	push QWORD [rbp-32]
	pop rax
	add rax, 24
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

foo8:
	push rbp
	mov rbp, rsp
	sub rsp, 48
	mov [rbp-8], rdi
	mov [rbp-16], rsi
	; define t
	lea rax, [rbp-48]
	push rax
	pop rax
	add rax, 0
	push rax
	push QWORD [rbp-16]
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-48]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 0
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
	lea rax, [rbp-48]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	add rax, 8
	push rax
	push QWORD [rbp-16]
	push 2
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-48]
	push rax
	pop rax
	add rax, 24
	push rax
	push QWORD [rbp-16]
	push 3
	pop rbx
	pop rax
	add rax, rbx
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-48]
	push rax
	pop rax
	mov rbx, [rbp-8]
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 32
	rep movsb
	mov rax, rbx
	mov rsp, rbp
	pop rbp
	ret

test8:
	push rbp
	mov rbp, rsp
	sub rsp, 96
	push STR_79
	pop rdi
	call println
	; define h
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	push 5000
	pop rdi
	call alloc
	push rax
	pop rax
	pop rbx
	mov [rbx], rax
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	push 1
	lea rdi, [rbp-56]
	pop rsi
	call foo8
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 32
	rep movsb
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 2
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	push 5
	lea rdi, [rbp-88]
	pop rsi
	call foo8
	push rax
	pop rax
	pop rbx
	mov rsi, rax
	mov rdi, rbx
	mov rcx, 32
	rep movsb
	push STR_80
	push 1
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_81
	push 2
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	push rax
	pop r13
	push STR_82
	push 3
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	push rax
	pop r13
	push STR_83
	push 4
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 24
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_84
	push 5
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 2
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_85
	push 6
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 2
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	push rax
	pop r13
	push STR_86
	push 7
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 2
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
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
	push rax
	pop r13
	push STR_87
	push 8
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 2
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	add rax, 24
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	; define tp
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 1
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	mov QWORD [rbp-96], rax
	push STR_88
	push 1
	push QWORD [rbp-96]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_89
	push 2
	push QWORD [rbp-96]
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
	push rax
	pop r13
	push STR_90
	push 3
	push QWORD [rbp-96]
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
	push rax
	pop r13
	push STR_91
	push 4
	push QWORD [rbp-96]
	pop rax
	add rax, 24
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	lea rax, [rbp-96]
	push rax
	lea rax, [rbp-24]
	push rax
	pop rax
	add rax, 8
	push rax
	pop rax
	push QWORD [rax]
	push 2
	pop rax
	pop rbx
	imul rax, 32
	add rbx, rax
	push rbx
	pop rax
	pop rbx
	mov [rbx], rax
	push STR_92
	push 5
	push QWORD [rbp-96]
	pop rax
	add rax, 0
	push rax
	pop rax
	push QWORD [rax]
	pop rdx
	pop rsi
	pop rdi
	call check_num
	push rax
	pop r13
	push STR_93
	push 6
	push QWORD [rbp-96]
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
	push rax
	pop r13
	push STR_94
	push 7
	push QWORD [rbp-96]
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
	push rax
	pop r13
	push STR_95
	push 8
	push QWORD [rbp-96]
	pop rax
	add rax, 24
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
	push rax
	pop r13
	call test1
	call test2
	call test3
	call test4
	call test5
	call test6
	call test7
	call test8
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
	STR_39: db "=====test0=====", 0
	STR_44: db "0x000003ffffffffff", 0
	STR_45: db "=====test1=====", 0
	STR_46: db "0xf", 0
	STR_47: db "0xe", 0
	STR_48: db "=====test2=====", 0
	STR_49: db "0xf", 0
	STR_50: db "=====test3=====", 0
	STR_51: db "if you see a # it's ok >?< here!", 0
	STR_54: db "=====test4=====", 0
	STR_55: db "2a", 0
	STR_56: db "2a", 0
	STR_57: db "=====test5=====", 0
	STR_60: db "0x7", 0
	STR_61: db "=====test6=====", 0
	STR_62: db "0x1", 0
	STR_63: db "0x2", 0
	STR_64: db "0x3", 0
	STR_65: db "0x4", 0
	STR_66: db "0x1", 0
	STR_67: db "0x2", 0
	STR_68: db "0x3", 0
	STR_69: db "0x4", 0
	STR_70: db "=====test7=====", 0
	STR_71: db "0x1", 0
	STR_72: db "0x2", 0
	STR_73: db "0x3", 0
	STR_74: db "0x4", 0
	STR_75: db "0x1", 0
	STR_76: db "0x2", 0
	STR_77: db "0x3", 0
	STR_78: db "0x4", 0
	STR_79: db "=====test8=====", 0
	STR_80: db "0x1", 0
	STR_81: db "0x2", 0
	STR_82: db "0x3", 0
	STR_83: db "0x4", 0
	STR_84: db "0x5", 0
	STR_85: db "0x6", 0
	STR_86: db "0x7", 0
	STR_87: db "0x8", 0
	STR_88: db "0x1", 0
	STR_89: db "0x2", 0
	STR_90: db "0x3", 0
	STR_91: db "0x4", 0
	STR_92: db "0x5", 0
	STR_93: db "0x6", 0
	STR_94: db "0x7", 0
	STR_95: db "0x8", 0
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
