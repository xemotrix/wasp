# WASP

A C-like language that compiles itself.

## Project overview

- `src/` the wasp compiler written in wasp
- `tests/` some wasp programs and the expected assembly output
- `examples/` bigger examples

## Requirements

- a wasp compiler binary (on the repo releases)
- nasm and ld
- some x86_64 linux to run it

## Setup

To recompile the wasp compiler and bootstrap it, run `make bootstrap`. It
will run a 3 round compilation comparing intermediate results.

Note that wasp outputs .s files: `wasp my_program.wasp -o out.s`. To make an
executable:
```
nasm -f elf64 out.s -o out.o
ld out.o -o out
```


## TODO

### IMPORTANT
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
