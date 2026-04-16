# WASP

A C-like language that compiles itself.

## Project overview

- `bootc/` the c wasp compiler
- `src/` the wasp compiler written in wasp
- `tests/` some wasp programs and the expected assembly output

## Requirements

- gcc (or a wasp compiler binary if I put it on the repo releases)
- nasm and ld
- some x86_64 linux to run it

## Setup

```bash
make setup
```

This will complete the bootstrap process from C:
1. Compile the c wasp compiler -> (A)
2. Compile the (wasp) wasp compliler with (A) -> (B)
3. Compile the (wasp) wasp compiler with (B) -> `wasp` binary

After that, `wasp` can be used to compile wasp programs. To recompile the
wasp compiler and bootstrap it, run `make bootstrap`.

Note that wasp outputs .s files: `wasp my_program.wasp -o out.s`. To make
an executable:
```
nasm -f elf64 out.s -o out.o
ld out.o -o out
```


## TODO

### IMPORTANT
- arena allocator -> hash map
- better error reportng;

### NTH
- SSA IR
- stack spillout for >6 function arguments;
- move more stuff to intrinsics? (assembly);
- for loops?;
- hex literals;

### MAYBE
- stack array?
- array literals?
- extern?
- stricter implicit casting? (so more type errors);
