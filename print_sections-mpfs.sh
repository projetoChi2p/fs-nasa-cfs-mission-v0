#!/bin/bash


# Check for input ELF file
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input.elf> [output_folder]"
    exit 1
fi

ELF_FILE=$1
/opt/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-objdump -h "$ELF_FILE"