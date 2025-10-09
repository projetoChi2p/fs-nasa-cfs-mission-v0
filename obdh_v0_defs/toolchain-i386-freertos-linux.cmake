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
set(CMAKE_SYSTEM_PROCESSOR i386)
set(CMAKE_CROSSCOMPILING 1)


add_compile_options(
    -Wfatal-errors              # Stop on first compilation error
)

set(OSAL_RAMDISK_FILESYSTEM_IS_MFS True)
set(CMAKE_VERBOSE_MAKEFILE true)


set(GCCPREFIX "x86_64-linux-gnu-")

find_program(CMAKE_C_COMPILER
  NAMES ${GCCPREFIX}gcc
  HINTS
    "/usr/bin/gcc"
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

# FBV 2024-12-03 Workaround for Ubuntu Linux 22 with GCC 11 for -m32
# See also $ gcc -m32 -v -x c /dev/null -c
include_directories(/usr/i686-linux-gnu/include)


GET_FILENAME_COMPONENT(MY_MISSION_DEFS_DIR "${CMAKE_CURRENT_LIST_FILE}"     DIRECTORY)
GET_FILENAME_COMPONENT(TOP_PROJECT_DIR     "${MY_MISSION_DEFS_DIR}/../"     REALPATH )
GET_FILENAME_COMPONENT(THIRDPARTY_DIR      "${TOP_PROJECT_DIR}/third-party" REALPATH )
GET_FILENAME_COMPONENT(OSAL_SOURCE_DIR     "${TOP_PROJECT_DIR}/osal"        REALPATH )
GET_FILENAME_COMPONENT(PSP_SOURCE_DIR      "${TOP_PROJECT_DIR}/psp"         REALPATH )
GET_FILENAME_COMPONENT(CFE_SOURCE_DIR      "${TOP_PROJECT_DIR}/cfe"         REALPATH )


set(OSAL_FREERTOS_INC_DIR          "${THIRDPARTY_DIR}/freertos-v10.5.1-v202212.01-gcc-posix/include")
set(OSAL_FREERTOS_SRC_DIR          "${THIRDPARTY_DIR}/freertos-v10.5.1-v202212.01-gcc-posix")

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
    ${OSAL_FREERTOS_SRC_DIR}/include
    ${OSAL_FREERTOS_SRC_DIR}/portable/ThirdParty/GCC/Posix
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


set(CFE_SYSTEM_PSPNAME      "pc-freertos-linux")
set(OSAL_SYSTEM_BSPTYPE     "pc-freertos-linux")
set(OSAL_SYSTEM_OSTYPE      "freertos")



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
add_compile_options(-m32) # i386 32 bits machine
add_compile_options(-fno-builtin)
add_compile_options(-std=gnu11)
add_compile_options(-fmessage-length=0)
add_compile_options(-ffunction-sections -fdata-sections)

add_link_options(-m32)
add_link_options(-lc)
add_link_options(-pthread)
add_link_options(-Wl,-Map=link.map) # Note: the same map file is being used for all programs! You may need to build a single target to get the correct map.

#set(CMAKE_ASM_FLAGS "-m32 -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

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
add_definitions(-DOS_TIMEBASE_TASK_STACK_SIZE=2048) # OSAL semantics, size in bytes
add_definitions(-DOS_TIMEBASE_TASK_PRIORITY=25)     # OSAL semantics, lower value is lower priority
add_definitions(-DBSP_MAIN_TASK_STACK_SIZE_BYTES=4096)
add_definitions(-DBSP_MAIN_TASK_PRIORITY=150)
add_definitions(-DFREERTOS_IDLE_TASK_STACK_SIZE_WORDS=128)
add_definitions(-DOS_CONSOLE_TASK_REPORT_TASKS=1) # FreeRTOS tasks and stack usage
add_definitions(-DOS_CONSOLE_TASK_REPORT_FILES=1) # FreeRTOS filesystem and files usage
add_definitions(-DOS_ASSERT_USE_TASK_NAME=1)      # Use OSAL task name inspection during assertions.


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
set (FREERTOS_PLATFORM_STACK_MIN_WORDS   "(PTHREAD_STACK_MIN/4)" ) # Is portSTACK_TYPE unsigned long?
math(EXPR FREERTOS_PLATFORM_HEAP_SIZE_BYTES "(256*1024)+(2048*512)")


configure_file("${MY_MISSION_DEFS_DIR}/FreeRTOSConfig.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/inc/FreeRTOSConfig.h")

message("+++ Leaving  toolchain cmake ${CMAKE_CURRENT_LIST_FILE}.")
