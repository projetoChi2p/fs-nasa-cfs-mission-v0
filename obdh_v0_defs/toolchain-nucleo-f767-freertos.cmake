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
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)


add_compile_options(
    -Wfatal-errors              # Stop on first compilation error
)

# We are reusing STM HAL for STM32
add_definitions(-DSTM32F767xx -DUSE_HAL_DRIVER)
add_definitions(-DHLP_MPU_SET_WRITE_THROUGH=0)
add_definitions(-DHLP_DATA_CACHE_ENABLE=1)
add_definitions(-DHLP_INSTRUCTION_CACHE_ENABLE=1)
add_definitions(-DART_ACCLERATOR_ENABLE=1)
add_definitions(-DPREFETCH_ENABLE=1)
set(OSAL_RAMDISK_FILESYSTEM_IS_MFS True)
set(CMAKE_VERBOSE_MAKEFILE true)


set(GCCPREFIX "arm-none-eabi-")

find_program(CMAKE_C_COMPILER
  NAMES ${GCCPREFIX}gcc
  HINTS
    "/opt/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin/"
  DOC "Find GNU GCC Toolchain"
  REQUIRED
)

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


# STM32F767Zi is CPUID 0x411FC270, hence r1p0
# See also FreeRTOS/portable/GCC/ARM_CM7/ReadMe.txt
# First implementation tests with NUCLEO-F767Zi used FreeRTOS 8.2.3 Cortex-M7 
# r0p1 (freertos-v8.2.3/portable/GCC/ARM_CM7/r0p1), but radiation tests
# were performed using FreeRTOS 10.2.1 Cortex-M4F (freertos-v10.2.1-stm32cubel4/portable/GCC/ARM_CM4F)
# See also build_all_all_cortex_m7all_stm32f767_nucleo_cmake
# -mlittle-endian
# -mthumb
# -mcpu=cortex-m7
# -mfloat-abi=hard -mfpu=fpv4-sp-d16

set(OSAL_FREERTOS_INC_DIR          "${THIRDPARTY_DIR}/freertos-v10.2.1-stm32cubel4/include")
set(OSAL_FREERTOS_SRC_DIR          "${THIRDPARTY_DIR}/freertos-v10.2.1-stm32cubel4")

if(OSAL_RAMDISK_FILESYSTEM_IS_MFS)
    set(OSAL_XILINX_MFS_SRC_DIR        "${THIRDPARTY_DIR}/xilinx-xilmfs-v2.3+")
else()
    set(OSAL_FREERTOS_PLUS_FAT_SRC_DIR "${THIRDPARTY_DIR}/freertos-plus-fat-2024-01-25-dev")
endif()

message("+++ Using MY_MISSION_DEFS_DIR '${MY_MISSION_DEFS_DIR}'.")
message("+++ Using TOP_PROJECT_DIR '${TOP_PROJECT_DIR}'.")
message("+++ Using THIRDPARTY_DIR '${THIRDPARTY_DIR}'.")
message("+++ Inside toolchain cmake ${CMAKE_CURRENT_LIST_FILE}.")
message("+++ Using OSAL_FREERTOS_INC_DIR '${OSAL_FREERTOS_INC_DIR}'.")
message("+++ Using OSAL_FREERTOS_SRC_DIR '${OSAL_FREERTOS_SRC_DIR}'.")
message("+++ Using OSAL_SOURCE_DIR '${OSAL_SOURCE_DIR}'.")


# FreeRTOS
include_directories(
    ${OSAL_FREERTOS_INC_DIR}
    ${OSAL_FREERTOS_SRC_DIR}/portable/GCC/ARM_CM4F
)

if(OSAL_RAMDISK_FILESYSTEM_IS_MFS)
    # Xilinx Memory Filesystem
    include_directories(
        ${OSAL_XILINX_MFS_SRC_DIR}/src
    )
else()
    # FreeRTOS + FAT Filesystem
    include_directories(
        ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}
        ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}/include
    )
endif()


# OSAL
include_directories(${OSAL_SOURCE_DIR}/src/os/shared/inc)
include_directories(${OSAL_SOURCE_DIR}/src/os/freertos/inc)


set(CFE_SYSTEM_PSPNAME      "nucleo-f767-freertos")
set(OSAL_SYSTEM_BSPTYPE     "nucleo-f767-freertos")
set(OSAL_SYSTEM_OSTYPE      "freertos")

set(LINKER_SCRIPT "${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/scripts/STM32F767ZITx_FLASH.ld")


# CMake default are:
# - Release: -O3
# - RelWithDebInfo: -O2
# - Debug: -g
# GCC default are:
# -O0

set(CMAKE_C_FLAGS_RELEASE          "          -O1 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_ASM_FLAGS_RELEASE        "          -O1 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO   "-g3 -ggdb -O1 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "-g3 -ggdb -O1 -DNDEBUG"    CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_C_FLAGS_DEBUG            "-g3 -ggdb -O1 -DDEBUG"     CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)
set(CMAKE_ASM_FLAGS_DEBUG          "-g3 -ggdb -O1 -DDEBUG"     CACHE STRING "Overriden by OSAL/cFS toolchain defs." FORCE)


add_compile_options(-Wall)
add_compile_options(-mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16)
add_compile_options(-fno-builtin)
add_compile_options(-std=gnu11)
add_compile_options(-fmessage-length=0)                              # No-wrap/Long compiler error messages
add_compile_options(-ffunction-sections -fdata-sections)             # Place functions and data in own section


add_link_options(-mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16)
add_link_options(-T ${LINKER_SCRIPT})
add_link_options(-specs=nano.specs)
add_link_options(-specs=nosys.specs)
add_link_options(-lc)
add_link_options(-Wl,-Map=link.map) # Note: the same map file is being used for all programs! You may need to build a single target to get the correct map.

#set(CMAKE_ASM_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")


 set(COMPILER_LINKER_OPTION_PREFIX "-Wl,")
 set(START_WHOLE_ARCHIVE "--whole-archive")
 set(STOP_WHOLE_ARCHIVE  "--no-whole-archive")
 set(START_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${START_WHOLE_ARCHIVE}")
 set(STOP_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${STOP_WHOLE_ARCHIVE}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE   NEVER)

include_directories(${PSP_SOURCE_DIR}/fsw/shared-freertos/inc)

include_directories(${OSAL_SOURCE_DIR}/src/bsp/shared-freertos/src)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/shared-freertos/vendor)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor)

# FreeRTOS BSP vendored code
include_directories(
    ${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor/CMSIS/Include
    ${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor/CMSIS/Device/ST/STM32F7xx/Include
    ${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor/STM32F7xx_HAL_Driver/Inc
)

# Include FreeRTOSConfig.h
include_directories(${OSAL_SOURCE_DIR}/../obdh_v0_defs/)

# FBV 2024-02-28 The include_directories below is only for debugging and should removed from final build.
include_directories(${CFE_SOURCE_DIR}/modules/es/fsw/src)
include_directories(${CFE_SOURCE_DIR}/modules/core_private/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/msg/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/core_api/fsw/inc)


message("+++ TARGETSYSTEM '${TARGETSYSTEM}'.")
message("+++ OSAL_SOURCE_DIR '${OSAL_SOURCE_DIR}'.")
message("+++ CMAKE_CURRENT_BINARY_DIR '${CMAKE_CURRENT_BINARY_DIR}'.")


# These OSAL configurations are specific to FreeRTOS and 
# have no mapping in osconfig.h.in
add_definitions(-DOS_TIMEBASE_TASK_STACK_SIZE=1024) # OSAL semantics, size in bytes
add_definitions(-DOS_TIMEBASE_TASK_PRIORITY=25)     # OSAL semantics, lower value is lower priority
add_definitions(-DBSP_MAIN_TASK_STACK_SIZE_BYTES=2048)
add_definitions(-DBSP_MAIN_TASK_PRIORITY=150)
add_definitions(-DFREERTOS_IDLE_TASK_STACK_SIZE_WORDS=128)
add_definitions(-DOS_CONSOLE_TASK_REPORT_TASKS=1) # FreeRTOS tasks and stack usage
add_definitions(-DOS_CONSOLE_TASK_REPORT_FILES=1) # FreeRTOS filesystem and files usage


if(OSAL_RAMDISK_FILESYSTEM_IS_MFS)
    #add_definitions(-DOS_FILESYSTEM_ROMDISK_IS_XILMFS=1) # Uses Xilinx MFS for ROM disks
    add_definitions(-DOS_FILESYSTEM_RAMDISK_IS_XILMFS=1) # Uses Xilinx MFS for RAM disks

    add_definitions(-DMFS_MAX_LOCAL_ENT=4)        # One entry takes (~ 8 + MFS_MAX_FILENAME_LENGTH) bytes
    add_definitions(-DMFS_BLOCK_DATA_SIZE=128)    # Must be same as CFE_PLATFORM_ES_RAM_DISK_SECTOR_SIZE
    add_definitions(-DMFS_MAX_FILENAME_LENGTH=20) # Must be >= OSAL_CONFIG_MAX_FILE_NAME
    add_definitions(-DMFS_MAX_OPEN_FILES=4)       # Must be >= OSAL_CONFIG_MAX_NUM_OPEN_FILES+OSAL_CONFIG_MAX_NUM_OPEN_DIRS
    add_definitions(-DMFS_MAX_FILESYSTEM=2)       # Must be >= OSAL_CONFIG_MAX_FILE_SYSTEMS
endif()

# These FreeRTOS configurations are applied to FreeRTOSConfig.h.in
set (FREERTOS_PLATFORM_STACK_MIN_WORDS        128)
math(EXPR FREERTOS_PLATFORM_HEAP_SIZE_BYTES "50 * 1024")


configure_file("${MY_MISSION_DEFS_DIR}/FreeRTOSConfig.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/inc/FreeRTOSConfig.h")

message("+++ Leaving  toolchain cmake ${CMAKE_CURRENT_LIST_FILE}.")
