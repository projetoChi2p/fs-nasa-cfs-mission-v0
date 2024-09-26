# fs-nasa-cfs-mission-v0

This repository contains the Flight-SIHFT project mission source code. The NASA cFS architecture was utilized, and the entire mission was built upon it.

For more information about cFS : <https://github.com/nasa/cFS>

The mission is composed by two benchmark applications: a fixed-point matrix multiplication benchmarck(mxm_app) and Huffman encoding and decoding benchmark (huff_app).
The SCH application was set up to send messages that trigger periodic execution of the two benchmark applications.
Upon receiving these messages, the benchmark applications perform a full processing cycle and send a message containing the benchmark results.
The TO application subscribes to these benchmark result messages and presents the results as telemetry to the spacecraft console.

# Setup
    sudo apt install make cmake gcc clang gcc-arm-none-eabi openocd
    git submodule init
    git submodule update

# Build
The unit test build process is simplified by scripts. For more information, check the official cFS documentation.

    ./build-mission-nucleo-f767-freertos.sh

# Run
To get the board ID:

    udevadm info -q property -p $(udevadm info -q path -n /dev/ttyACM0) | grep ID_SERIAL_SHORT

To program the NUCLEO-F767ZI:

    openocd -s /usr/share/openocd/scripts/  --file board/stm32f7discovery.cfg --command "hla_serial ID_SERIAL_SHORT; program path/to/file.elf verify reset exit"
