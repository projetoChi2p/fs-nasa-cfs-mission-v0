#!/bin/bash

# set -o xtrace
set -e  # -e Exit immediately if a command exits with a non-zero status.


THIS_SCRIPT=${BASH_SOURCE[0]}
THIS_SCRIPT_FULLNAME=$(realpath "$THIS_SCRIPT")
THIS_SCRIPT=$(basename "${THIS_SCRIPT_FULLNAME}")
ROOT_DIR=$(dirname "$THIS_SCRIPT_FULLNAME")

ELF_FILE=$1

if [ -z "$ELF_FILE" ]; then
    echo "Missing PolarFire RISC-V .elf file. Using default."
    #echo "Usage $0 <.elf file>"
    #exit -1
    ELF_FILE=./build_obdh_v0_mpfs-discovery-freertos/mpfs-discovery-freertos/default_cpu1/cpu1/core-cpu1
fi

if [ ! -x /usr/bin/expect ]; then
    echo "Missing expect."
    echo "Install e.g. sudo apt install expect"
    exit -3
fi

# ELF_FILE=/media/fabiob/portdev/nn-apsoc-polarfire/sc2022.2-747.ws/mpfs-gpio-interrupt/LIM-Debug/mpfs-gpio-interrupt.elf
# ELF_LD_ADDRESS=0x8000000
# ELF_BOOT_ADDRESS=0x8000000

if [ -d $HOME/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc ]; then
    MICROCHIP_TOOLS=$HOME/Microchip
elif [ -d /home/tools/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc ]; then
    MICROCHIP_TOOLS=/home/tools/Microchip
elif [ -d /opt/Microchip/SoftConsole-v2022.2-RISC-V-747/riscv-unknown-elf-gcc ]; then
    MICROCHIP_TOOLS=/opt/Microchip
else
    echo "Error: Toolchain not found."
    exit -2
fi

SC_HOME="${MICROCHIP_TOOLS}/SoftConsole-v2022.2-RISC-V-747"

OPENOCD_HOME="${SC_HOME}/openocd"
OPENOCD_EXEC=${OPENOCD_HOME}/bin/openocd
OPENOCD_SCRIPTS=${OPENOCD_HOME}/share/openocd/scripts
GDB_EXEC=${SC_HOME}/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-gdb
GDB_INIT=${SC_HOME}/gdbinit/softconsole.gdbinit


# Prepare temporary GDB script
cat <<EOT > ${THIS_SCRIPT_FULLNAME}.gdb.tmp
set architecture riscv:rv64
file ${ELF_FILE}
set mem inaccessible-by-default off
set \$target_riscv=1
set arch riscv:rv64
source ${GDB_INIT}
target remote localhost:3333
load ${ELF_FILE}
thread apply all set \$pc=_start
EOT


# Prepare temporary Expect interaction script
cat <<EOT > ${THIS_SCRIPT_FULLNAME}.expect.tmp
#!/usr/bin/expect

spawn telnet localhost 4444
expect "Escape character is"
send "shutdown\n"
expect "Connection closed by foreign host."
expect eof

exit 0
EOT


# Run openocd in background
${OPENOCD_EXEC} \
    --search ${OPENOCD_SCRIPTS} \
    --command "set DEVICE MPFS" \
    --file board/microsemi-riscv.cfg \
    --command "init; reset halt; sleep 200" &

OPENOCD_PID=$!
trap "kill ${OPENOCD_PID} 2>/dev/null" EXIT


# Start GDB to debug
${GDB_EXEC} --command=${THIS_SCRIPT_FULLNAME}.gdb.tmp

# Connect to openocd and terminate
# /usr/bin/expect ${THIS_SCRIPT_FULLNAME}.expect.tmp

# exit 0