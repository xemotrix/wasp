.PHONY: bootstrap

bootstrap_compile:
	./wasp boot/wasp.wasp -o boot.s
	nasm -f elf64 boot.s -o boot.o
	ld boot.o -o bootstrap
	./bootstrap boot/wasp.wasp -o boot.s
	nasm -f elf64 boot.s -o boot.o
	ld boot.o -o wasp
	rm bootstrap

bootstrap: bootstrap_compile clean

asmboot:
	nasm -f elf64 boot.s -o boot.o
	ld boot.o -o bootstrap

fromc:
	gcc -Wall -g c/*.c -o lang
	./lang boot/wasp.wasp
	nasm -f elf64 out.s -o out.o
	ld out.o -o out
	./out boot/wasp.wasp -o boot.s
	nasm -f elf64 boot.s -o boot.o
	ld boot.o -o wasp
	rm lang
	rm out

clean:
	rm -f *.o
	rm -f *.s

setup: fromc bootstrap clean
	echo "wasp binary generated"

asm:
	nasm -f elf64 out.s -o out.o
	ld out.o -o out
	./out

compc:
	gcc -Wall -g *.c -o lang

