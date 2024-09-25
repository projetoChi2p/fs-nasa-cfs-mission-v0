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


set(CMAKE_C_FLAGS_RELEASE          "-O1 -DNDEBUG"    CACHE STRING "Overriden" FORCE)
set(CMAKE_ASM_FLAGS_RELEASE        "-O1 -DNDEBUG"    CACHE STRING "Overriden" FORCE)

set(CMAKE_C_FLAGS_RELWITHDEBINFO   "-g -O1 -DNDEBUG" CACHE STRING "Overriden" FORCE)
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "-g -O1 -DNDEBUG" CACHE STRING "Overriden" FORCE)


set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)

add_compile_options(
    #-std=c99                    # Target the C99 standard (without gcc extensions)
)

# We are reusing STM HAL for STM32
add_definitions(-DSTM32F767xx -DUSE_HAL_DRIVER)

add_definitions(-DHLP_MPU_SET_WRITE_THROUGH=0)

add_definitions(-DHLP_DATA_CACHE_ENABLE=1)
add_definitions(-DHLP_INSTRUCTION_CACHE_ENABLE=1)
add_definitions(-DART_ACCLERATOR_ENABLE=1)
add_definitions(-DPREFETCH_ENABLE=1)

# add_definitions(-DHLP_DATA_CACHE_ENABLE=0)
# add_definitions(-DHLP_INSTRUCTION_CACHE_ENABLE=0)
# add_definitions(-DART_ACCLERATOR_ENABLE=0)
# add_definitions(-DPREFETCH_ENABLE=0)


set(GCCPATH )
set(GCCPREFIX "arm-none-eabi-")


# toolchain is installed to $PATH
set(CMAKE_C_COMPILER            "${GCCPREFIX}gcc")
set(CMAKE_CXX_COMPILER          "${GCCPREFIX}g++")
set(CMAKE_AS                    "${GCCPREFIX}as")
set(CMAKE_ASM_COMPILER          "${GCCPREFIX}gcc")
set(CMAKE_OBJCOPY               "${GCCPREFIX}objcopy")
set(CMAKE_OBJDUMP               "${GCCPREFIX}objdump")
set(CMAKE_SIZE                  "${GCCPREFIX}size")
set(CMAKE_AR                    "${GCCPREFIX}ar" CACHE FILEPATH "archiver-bug") # https://stackoverflow.com/a/43777707/1545769

#add_definitions(-include osconfig.h)

#set(DOCKER_HOST_PROJECT_DIR "$ENV{DOCKER_HOST_PROJECT_DIR}")
#set(DOCKER_CONTAINER_PROJECT_DIR "$ENV{DOCKER_CONTAINER_PROJECT_DIR}")
#if(NOT DOCKER_HOST_PROJECT_DIR OR NOT DOCKER_CONTAINER_PROJECT_DIR)
#    message(FATAL_ERROR "You must export the environment variable \${DOCKER_HOST_PROJECT_DIR} \${DOCKER_CONTAINER_PROJECT_DIR}.")
#endif()


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


set(OSAL_FREERTOS_INC_DIR          "${THIRDPARTY_DIR}/include-freertos-v10.2.1-stm32cubel4")
set(OSAL_FREERTOS_SRC_DIR          "${THIRDPARTY_DIR}/freertos-v10.2.1-stm32cubel4")
#set(OSAL_FREERTOS_CONFIG_H_DIR     "${THIRDPARTY_DIR}/bsp-pc-linux-i386/inc")
set(OSAL_FREERTOS_PLUS_FAT_SRC_DIR "${THIRDPARTY_DIR}/freertos-plus-fat-2024-01-25-dev")

message("+++ Using MY_MISSION_DEFS_DIR '${MY_MISSION_DEFS_DIR}'.")
message("+++ Using TOP_PROJECT_DIR '${TOP_PROJECT_DIR}'.")
message("+++ Using THIRDPARTY_DIR '${THIRDPARTY_DIR}'.")
message("+++ Inside toolchain cmake ${CMAKE_CURRENT_LIST_FILE}.")
message("+++ Using OSAL_FREERTOS_INC_DIR '${OSAL_FREERTOS_INC_DIR}'.")
message("+++ Using OSAL_FREERTOS_SRC_DIR '${OSAL_FREERTOS_SRC_DIR}'.")
message("+++ Using OSAL_SOURCE_DIR '${OSAL_SOURCE_DIR}'.")
#message("+++ Using CMAKE_BINARY_DIR '${CMAKE_BINARY_DIR}'.")
#message("+++ Using CMAKE_CURRENT_SOURCE_DIR '${CMAKE_CURRENT_SOURCE_DIR}'.")
#message("+++ Using OSAL_API_INCLUDE_DIRECTORIES '${OSAL_API_INCLUDE_DIRECTORIES}'.")
#message("+++ Using PROJECT_SOURCE_DIR '${PROJECT_SOURCE_DIR}'.")
#message("+++ Using MISSION_DEFS '${MISSION_DEFS}'.")
#message("+++ Using BSPTYPE '${OSAL_SYSTEM_BSPTYPE}'.")


# FreeRTOS
#include_directories(${OSAL_FREERTOS_CONFIG_H_DIR})
include_directories(${OSAL_FREERTOS_INC_DIR})
include_directories(${OSAL_FREERTOS_SRC_DIR}/include)
include_directories(${OSAL_FREERTOS_SRC_DIR}/portable/GCC/ARM_CM4F)


# FreeRTOS + FAT
include_directories(
    ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}
    ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}/include
)


# OSAL
include_directories(${OSAL_SOURCE_DIR}/src/os/shared/inc)
include_directories(${OSAL_SOURCE_DIR}/src/os/freertos/inc)


set(CFE_SYSTEM_PSPNAME      "nucleo-f767-freertos")
set(OSAL_SYSTEM_BSPTYPE     "nucleo-f767-freertos")
set(OSAL_SYSTEM_OSTYPE      "freertos")


#set(GDB_FLAGS "-g3 -O0 -fdebug-prefix-map=${DOCKER_CONTAINER_PROJECT_DIR}=${DOCKER_HOST_PROJECT_DIR}")
set(GDB_FLAGS "-g3 -O1")
set(MCPU_FLAGS "-mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(CMAKE_C_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} ${VFP_FLAGS} -Wall -fno-builtin -std=gnu11 -fmessage-length=0 -ffunction-sections -fdata-sections" CACHE INTERNAL "c compiler flags" FORCE)
set(CMAKE_CXX_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} ${VFP_FLAGS} -Wall -fno-builtin -fmessage-length=0 -ffunction-sections -fdata-sections" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")
#set(CMAKE_EXE_LINKER_FLAGS "-specs=nano.specs --specs=rdimon.specs -lc -lrdimon" CACHE INTERNAL "exe link flags" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "-specs=nosys.specs -specs=nano.specs -lc" CACHE INTERNAL "exe link flags" FORCE)

set(LINKER_SCRIPT "${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/scripts/STM32F767ZITx_FLASH.ld")
#if(NOT DEFINED LINKER_SCRIPT)
#    message(FATAL_ERROR "You must export the environment variable \${LINKER_SCRIPT}.")
#endif()
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T ${LINKER_SCRIPT} -Wl,-Map,link.map" CACHE INTERNAL "exe link flags" FORCE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE   NEVER)


include_directories(${PSP_SOURCE_DIR}/fsw/shared-freertos/inc)

include_directories(${OSAL_SOURCE_DIR}/src/bsp/shared-freertos/vendor)
# FreeRTOS BSP vendored code
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor/CMSIS/Include)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor/CMSIS/Device/ST/STM32F7xx/Include)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor/STM32F7xx_HAL_Driver/Inc)

# Include FreeRTOSConfig.h
include_directories(${OSAL_SOURCE_DIR}/../obdh_v0_defs/)

 set(COMPILER_LINKER_OPTION_PREFIX "-Wl,")
 set(START_WHOLE_ARCHIVE "--whole-archive")
 set(STOP_WHOLE_ARCHIVE  "--no-whole-archive")
 set(START_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${START_WHOLE_ARCHIVE}")
 set(STOP_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${STOP_WHOLE_ARCHIVE}")

# FBV 2024-02-28 The include_directories below is only for debugging and should removed from final build.
include_directories(${CFE_SOURCE_DIR}/modules/es/fsw/src)
include_directories(${CFE_SOURCE_DIR}/modules/core_private/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/msg/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/core_api/fsw/inc)
