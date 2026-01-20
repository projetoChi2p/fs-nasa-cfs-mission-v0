#[[
    GSC-18128-1, "Core Flight Executive Version 6.7"

    Copyright (c) 2006-2019 United States Government as represented by
    the Administrator of the National Aeronautics and Space Administration.
    All Rights Reserved.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0 AND (Apache-2.0 OR MIT-0)

    Modifications in this file authored by Patrick Paul are available under either the Apache-2.0 or MIT-0 license.
]]

set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)
set(CMAKE_CROSSCOMPILING 1)


add_compile_options(
    -Wall
    -Wextra
    -Wpedantic
    # -Werror                     # Treat warnings as errors (code should be clean)
    -Wfatal-errors              # Stop on first compilation error
    -Wno-error=sign-compare     # There are signed/unsigned comparisons in NASA's support code for unit tests.
    -Wno-error=unused-variable  # Waive unused variable warning present on Microchip source code.
    -Wno-error=unused-parameter # There are unused parameters in OSAL common code from NASA.
)

add_definitions(-DRISCV_NOELV -DCPU_FREQUENCY=50000000UL)

# NOEL-V GP system target (cmake -DCONFIG_NOELV_GP=1)
if(NOT DEFINED CONFIG_NOELV_GP)
    # NOEL-V GP system target (export CONFIG_NOELV_GP=1)
    if(DEFINED ENV{CONFIG_NOELV_GP})
        set(CONFIG_NOELV_GP $ENV{CONFIG_NOELV_GP})
    endif()
endif()

if (CONFIG_NOELV_GP)
    add_definitions(-DCONFIG_NOELV_GP=1) # Build for NOEL-V GP system target
endif()


# add_definitions(-DFREERTOS_TRACE_ENABLED)
# add_definitions(-DENABLE_FI)

set(CMAKE_VERBOSE_MAKEFILE true)

# Xilinx Memory Filesystem
set(OSAL_RAMDISK_FILESYSTEM_IS_MFS               True)
# FreeRTOS+ FAT Filesystem
set(OSAL_RAMDISK_FILESYSTEM_IS_FREERTOS_PLUS_FAT False)
# ChaN FatFs
set(OSAL_NON_VOLATILE_FILESYSTEM_IS_FATFS        False)

set(TO_CON_APP_USE_STATIC_TABLE  True)
set(SCH_LAB_APP_USE_STATIC_TABLE True)


set(GCCPREFIX $ENV{RISCV_GCC_TRIPLET})
if ("${GCCPREFIX}" STREQUAL "")
    set(GCCPREFIX   "riscv64-unknown-elf-")
endif()


set(RISCV_GCC_PATH $ENV{RISCV_GCC_PATH})
if ("${RISCV_GCC_PATH}" STREQUAL "")
    find_program(CMAKE_C_COMPILER
        NAMES ${GCCPREFIX}gcc
        HINTS
            "/opt/riscv-gnu-toolchain-15.1.0-2025.12.27-multilib/bin"
        DOC "Find GNU GCC Toolchain"
        REQUIRED
    )
else()
    find_program(CMAKE_C_COMPILER
        NAMES ${GCCPREFIX}gcc
        HINTS
            "${RISCV_GCC_PATH}/bin/"
        DOC "Find GNU GCC Toolchain"
        REQUIRED
    )
endif()



GET_FILENAME_COMPONENT(GCCPATH      "${CMAKE_C_COMPILER}"                 DIRECTORY)
string(APPEND GCCPATH "/")

message("+++ Using GCC from '${GCCPATH}'.")

set(CMAKE_C_COMPILER            "${GCCPATH}${GCCPREFIX}gcc")
set(CMAKE_CXX_COMPILER          "${GCCPATH}${GCCPREFIX}g++")
set(CMAKE_AS                    "${GCCPATH}${GCCPREFIX}as")
set(CMAKE_ASM_COMPILER          "${GCCPATH}${GCCPREFIX}gcc")
set(CMAKE_OBJCOPY               "${GCCPATH}${GCCPREFIX}objcopy")
set(CMAKE_OBJDUMP               "${GCCPATH}${GCCPREFIX}objdump")
set(CMAKE_SIZE                  "${GCCPATH}${GCCPREFIX}size")
set(CMAKE_AR                    "${GCCPATH}${GCCPREFIX}ar")


GET_FILENAME_COMPONENT(MY_MISSION_DEFS_DIR "${CMAKE_CURRENT_LIST_FILE}"     DIRECTORY)
GET_FILENAME_COMPONENT(TOP_PROJECT_DIR     "${MY_MISSION_DEFS_DIR}/../"     REALPATH )
GET_FILENAME_COMPONENT(THIRDPARTY_DIR      "${TOP_PROJECT_DIR}/third-party" REALPATH )
GET_FILENAME_COMPONENT(OSAL_SOURCE_DIR     "${TOP_PROJECT_DIR}/osal"        REALPATH )
GET_FILENAME_COMPONENT(PSP_SOURCE_DIR      "${TOP_PROJECT_DIR}/psp"         REALPATH )
GET_FILENAME_COMPONENT(CFE_SOURCE_DIR      "${TOP_PROJECT_DIR}/cfe"         REALPATH )


set(OSAL_FREERTOS_INC_DIR          "${THIRDPARTY_DIR}/freertos-v10.5.1-gcc-riscv/include")
set(OSAL_FREERTOS_SRC_DIR          "${THIRDPARTY_DIR}/freertos-v10.5.1-gcc-riscv")

if(OSAL_RAMDISK_FILESYSTEM_IS_MFS)
    set(OSAL_XILINX_MFS_SRC_DIR        "${THIRDPARTY_DIR}/xilinx-xilmfs-v2.3+")
endif()

if(OSAL_RAMDISK_FILESYSTEM_IS_FREERTOS_PLUS_FAT)
    set(OSAL_FREERTOS_PLUS_FAT_SRC_DIR "${THIRDPARTY_DIR}/freertos-plus-fat-2024-01-25-dev")
endif()

if (OSAL_NON_VOLATILE_FILESYSTEM_IS_FATFS)
    set(OSAL_FATFS_SRC_DIR "${THIRDPARTY_DIR}/fatfs")
    set(OSAL_FATFS_INC_DIR "${THIRDPARTY_DIR}/fatfs")
endif()

message("+++ Using MY_MISSION_DEFS_DIR '${MY_MISSION_DEFS_DIR}'.")
message("+++ Using TOP_PROJECT_DIR '${TOP_PROJECT_DIR}'.")
message("+++ Using THIRDPARTY_DIR '${THIRDPARTY_DIR}'.")
message("+++ Inside toolchain cmake ${CMAKE_CURRENT_LIST_FILE}.")
message("+++ Using OSAL_FREERTOS_INC_DIR '${OSAL_FREERTOS_INC_DIR}'.")
message("+++ Using OSAL_FREERTOS_SRC_DIR '${OSAL_FREERTOS_SRC_DIR}'.")
message("+++ Using OSAL_SOURCE_DIR '${OSAL_SOURCE_DIR}'.")



if(OSAL_RAMDISK_FILESYSTEM_IS_MFS)
    include_directories(
        ${OSAL_XILINX_MFS_SRC_DIR}/src
    )
endif()

if(OSAL_RAMDISK_FILESYSTEM_IS_FREERTOS_PLUS_FAT)
    include_directories(
        ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}
        ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}/include
    )
endif()

if (OSAL_NON_VOLATILE_FILESYSTEM_IS_FATFS)
    include_directories(
        ${OSAL_FATFS_INC_DIR}
    )
endif()


# OSAL
include_directories(${OSAL_SOURCE_DIR}/src/os/shared/inc)
include_directories(${OSAL_SOURCE_DIR}/src/os/freertos/inc)


set(CFE_SYSTEM_PSPNAME      "noelv-freertos")
set(OSAL_SYSTEM_BSPTYPE     "noelv-freertos")
set(OSAL_SYSTEM_OSTYPE      "freertos")

#set(LINKER_SCRIPT "${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/scripts/link_ram_ddr.ld")
set(LINKER_SCRIPT "${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/scripts/link_xip_ddr.ld")
#set(LINKER_SCRIPT "${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/scripts/link_ddr_ddr.ld")

# CMake default are:
# - Release: -O3
# - RelWithDebInfo: -O2
# - Debug: -g
# GCC default are:
# -O0

set(CMAKE_C_FLAGS_RELEASE          "          -O3 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_ASM_FLAGS_RELEASE        "          -O3 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO   "-g3 -ggdb -O1 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "-g3 -ggdb -O1 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_C_FLAGS_DEBUG            "-g3 -ggdb -O0 -DDEBUG"     CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_ASM_FLAGS_DEBUG          "-g3 -ggdb -O0 -DDEBUG"     CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)


set(RISCV_MARCH $ENV{RISCV_MARCH})
if ("${RISCV_MARCH}" STREQUAL "")
    set(RISCV_MARCH "rv64imafdc")
endif()

set(RISCV_MABI $ENV{RISCV_MABI})
if ("${RISCV_MABI}" STREQUAL "")
    set(RISCV_MABI "lp64d")
endif()


add_compile_options(-Wall)
add_compile_options(-march=${RISCV_MARCH})                # For integer-only/soft-float, use rv64imac/lp64"
add_compile_options(-mabi=${RISCV_MABI})
add_compile_options(-msmall-data-limit=8)
add_compile_options(-mcmodel=medany)                      # Memory model: how sparse memory addresses can be (medlow/medany/large)
add_compile_options(-mstrict-align)                       # Memory access alignment
add_compile_options(-mno-save-restore)                    # Prologue and epilogue code
add_compile_options(-fmessage-length=0)                   # No-wrap/Long compiler error messages
add_compile_options(-fsigned-char)                        # C/C++ char is signed
add_compile_options(-ffunction-sections -fdata-sections)  # Place functions and data in own section

add_compile_options(-frecord-gcc-switches)                # Keep track of compilation inside object files


add_link_options(-march=${RISCV_MARCH})                   # When using newer GCC, may require "rv64ima_zicsr_zifencei"
add_link_options(-mabi=${RISCV_MABI})
add_link_options(-mcmodel=medany)                         # When using DDR, may require -mcmodel=medany
add_link_options(-T ${LINKER_SCRIPT})
add_link_options(-nostartfiles -Wl,--gc-sections)
add_link_options(-specs=nano.specs)
add_link_options(-specs=nosys.specs)
add_link_options(-Wl,-Map=link.map) # Note: the same map file is being used for all programs! You may need to build a single target to get the correct map.

#set(COMPILER_LINKER_OPTION_PREFIX "-Wl,")
#set(START_WHOLE_ARCHIVE "--whole-archive")
#set(STOP_WHOLE_ARCHIVE  "--no-whole-archive")
#set(START_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${START_WHOLE_ARCHIVE}")
#set(STOP_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${STOP_WHOLE_ARCHIVE}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE   NEVER)

include_directories(${PSP_SOURCE_DIR}/fsw/shared-freertos/inc)

include_directories(${OSAL_SOURCE_DIR}/src/bsp/shared-freertos/src)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/shared-freertos/vendor)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor)

# FreeRTOS
include_directories(
    ${OSAL_FREERTOS_INC_DIR}
    ${OSAL_FREERTOS_SRC_DIR}/include
    ${OSAL_FREERTOS_SRC_DIR}/portable/GCC/RISC-V
)

# FreeRTOS BSP vendored code
include_directories(
    ${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor
)



# FBV 2024-02-28 The include_directories below is only for debugging and should removed from final build.
include_directories(${CFE_SOURCE_DIR}/modules/es/fsw/src)
include_directories(${CFE_SOURCE_DIR}/modules/core_private/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/msg/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/core_api/fsw/inc)


message("+++ TARGETSYSTEM '${TARGETSYSTEM}'.")
message("+++ OSAL_SOURCE_DIR '${OSAL_SOURCE_DIR}'.")
message("+++ CMAKE_CURRENT_BINARY_DIR '${CMAKE_CURRENT_BINARY_DIR}'.")

# For NOEL-V MC-lite running at 50 MHz
#add_definitions(-DMSG_MXM_HUFF_WORK_TICKS=15)

# These OSAL configurations are specific to FreeRTOS and
# have no mapping in osconfig.h.in
add_definitions(-DOS_TIMEBASE_TASK_STACK_SIZE=2048) # OSAL semantics, size in bytes
add_definitions(-DOS_TIMEBASE_TASK_PRIORITY=25)     # OSAL semantics, lower value is lower priority
add_definitions(-DBSP_MAIN_TASK_STACK_SIZE_BYTES=6144)
add_definitions(-DBSP_MAIN_TASK_PRIORITY=150)
add_definitions(-DFREERTOS_IDLE_TASK_STACK_SIZE_WORDS=256)
#add_definitions(-DOS_CONSOLE_TASK_REPORT_TASKS=1) # FreeRTOS tasks and stack usage
#add_definitions(-DOS_CONSOLE_TASK_REPORT_FILES=1) # FreeRTOS filesystem and files usage
#add_definitions(-DIDLE_TASK_REPORT_TASKS=1)       # FreeRTOS tasks and stack usage
add_definitions(-DOS_ASSERT_USE_TASK_NAME=1)      # Use OSAL task name inspection during assertions.
#add_definitions(-DFREERTOS_TRACE_ENABLED=1)

if(OSAL_RAMDISK_FILESYSTEM_IS_MFS)
    #add_definitions(-DOS_FILESYSTEM_ROMDISK_IS_XILMFS=1) # Uses Xilinx MFS for ROM disks
    add_definitions(-DOS_FILESYSTEM_RAMDISK_IS_XILMFS=1) # Uses Xilinx MFS for RAM disks

    add_definitions(-DMFS_MAX_LOCAL_ENT=4)        # One entry takes (~ 8 + MFS_MAX_FILENAME_LENGTH) bytes
    add_definitions(-DMFS_BLOCK_DATA_SIZE=128)    # Must be same as CFE_PLATFORM_ES_RAM_DISK_SECTOR_SIZE
    add_definitions(-DMFS_MAX_FILENAME_LENGTH=20) # Must be >= OSAL_CONFIG_MAX_FILE_NAME
    add_definitions(-DMFS_MAX_OPEN_FILES=4)       # Must be >= OSAL_CONFIG_MAX_NUM_OPEN_FILES+OSAL_CONFIG_MAX_NUM_OPEN_DIRS
    add_definitions(-DMFS_MAX_FILESYSTEM=2)       # Must be >= OSAL_CONFIG_MAX_FILE_SYSTEMS
endif()

if (OSAL_NON_VOLATILE_FILESYSTEM_IS_FATFS)
    add_definitions(-DOS_FILESYSTEM_NON_VOLATILE_IS_FATFS=1)
endif()

# These FreeRTOS configurations are applied to FreeRTOSConfig.h.in
set (FREERTOS_PLATFORM_STACK_MIN_WORDS      512)
math(EXPR FREERTOS_PLATFORM_HEAP_SIZE_BYTES "120 * 1024")


configure_file("${MY_MISSION_DEFS_DIR}/FreeRTOSConfig.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/inc/FreeRTOSConfig.h")

message("+++ Leaving toolchain cmake ${CMAKE_CURRENT_LIST_FILE}.")
