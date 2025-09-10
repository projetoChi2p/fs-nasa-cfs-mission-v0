#!/bin/bash

# Check for input ELF file
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input.elf> [output_folder]"
    exit 1
fi

ELF_FILE=$1
BASENAME=$(basename "$ELF_FILE" .elf)
OUTPUT_FOLDER=${2:-"extracted_images"} # Default to "output" folder if not provided

# Check if the file exists
if [ ! -f "$ELF_FILE" ]; then
    echo "Error: File $ELF_FILE not found!"
    exit 1
fi


rm -rf "$OUTPUT_FOLDER"
# Create the output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"


echo "Generating .bin image..."
/opt/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-objcopy -O binary "${ELF_FILE}" "${OUTPUT_FOLDER}/image.bin"

echo "Generating .hex image..."
/opt/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-objcopy -O ihex "${ELF_FILE}" "${OUTPUT_FOLDER}/image.hex"

echo "Generating .srec image..."
/opt/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-objcopy -O srec "${ELF_FILE}" "${OUTPUT_FOLDER}/image.srec"

# Display results
echo "Extraction complete. File saved in '${OUTPUT_FOLDER}':"
echo "  ${BASENAME}.elf -> ${OUTPUT_FOLDER}/image.bin"
echo "  ${BASENAME}.elf -> ${OUTPUT_FOLDER}/image.hex"
echo "  ${BASENAME}.elf -> ${OUTPUT_FOLDER}/image.srec"
