#!/usr/bin/env bash
set -e

echo "1 compile bootstrap..."
./wasp src/wasp.wasp -o boot.s
nasm -f elf64 boot.s -o boot.o
ld boot.o -o bootstrap

echo "2 rebuild with bootstrap compiler..."
./bootstrap src/wasp.wasp -o boot.s
nasm -f elf64 boot.s -o boot.o
ld boot.o -o wasp1

echo "3 full self compile..."
./bootstrap src/wasp.wasp -o wasp.s
nasm -f elf64 wasp.s -o boot.o
ld boot.o -o wasp2

echo "4 verifying reproducibility..."
if command -v delta >/dev/null 2>&1; then
    DIFF_TOOL="delta"
else
    DIFF_TOOL="diff"
fi

if ! $DIFF_TOOL boot.s wasp.s; then
    echo "ERROR: bootstrap is not reproducible (boot.s != wasp.s)"
    exit 1
fi

echo "SUCCESS: bootstrap is reproducible"
mv ./wasp2 ./wasp

rm -f bootstrap wasp1 wasp2 boot.s wasp.s boot.o
