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

#[[
add_compile_options(
    -Werror                     # Treat warnings as errors (code should be clean)
)
]]


set(GCCPATH )
set(GCCPREFIX )


# toolchain is installed to $PATH in Docker container
set(CMAKE_C_COMPILER            "${GCCPREFIX}gcc")
set(CMAKE_CXX_COMPILER          "${GCCPREFIX}g++")
set(CMAKE_AS                    "${GCCPREFIX}as")
set(CMAKE_ASM_COMPILER          "${GCCPREFIX}gcc")
set(CMAKE_OBJCOPY               "objcopy")
set(CMAKE_OBJDUMP               "objdump")
set(CMAKE_SIZE                  "size")
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

set(OSAL_FREERTOS_INC_DIR          "${THIRDPARTY_DIR}/include-freertos-v10.5.1-gcc-posix")
set(OSAL_FREERTOS_SRC_DIR          "${THIRDPARTY_DIR}/freertos-v10.5.1-v202212.01-gcc-posix")
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
include_directories(${OSAL_FREERTOS_SRC_DIR}/portable/ThirdParty/GCC/Posix)

# FreeRTOS + FAT
include_directories(
    ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}
    ${OSAL_FREERTOS_PLUS_FAT_SRC_DIR}/include
)


# OSAL
include_directories(${OSAL_SOURCE_DIR}/src/os/shared/inc)
include_directories(${OSAL_SOURCE_DIR}/src/os/freertos/inc)


set(CFE_SYSTEM_PSPNAME      "pc-freertos-linux")
set(OSAL_SYSTEM_BSPTYPE     "pc-freertos-linux")
set(OSAL_SYSTEM_OSTYPE      "freertos")


#set(GDB_FLAGS "-g3 -O0 -fdebug-prefix-map=${DOCKER_CONTAINER_PROJECT_DIR}=${DOCKER_HOST_PROJECT_DIR}")
set(GDB_FLAGS "-g3 -O0")
set(MCPU_FLAGS "-m32")
set(CMAKE_C_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} ${VFP_FLAGS} -Wall -fno-builtin -std=gnu11 -fmessage-length=0 -ffunction-sections -fdata-sections" CACHE INTERNAL "c compiler flags" FORCE)
set(CMAKE_CXX_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} ${VFP_FLAGS} -Wall -fno-builtin -fmessage-length=0 -ffunction-sections -fdata-sections" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "${GDB_FLAGS} ${MCPU_FLAGS} -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")
#set(CMAKE_EXE_LINKER_FLAGS "-specs=nano.specs --specs=rdimon.specs -lc -lrdimon" CACHE INTERNAL "exe link flags" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "-lc -pthread" CACHE INTERNAL "exe link flags" FORCE)

#set(LINKER_SCRIPT "$ENV{LINKER_SCRIPT}")
#if(NOT DEFINED LINKER_SCRIPT)
#    message(FATAL_ERROR "You must export the environment variable \${LINKER_SCRIPT}.")
#endif()
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map,link.map" CACHE INTERNAL "exe link flags" FORCE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY   NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE   NEVER)



include_directories(${PSP_SOURCE_DIR}/fsw/shared-freertos/inc)

include_directories(${OSAL_SOURCE_DIR}/src/bsp/shared-freertos/vendor)
include_directories(${OSAL_SOURCE_DIR}/src/bsp/${OSAL_SYSTEM_BSPTYPE}/vendor)

# Include FreeRTOSConfig.h
include_directories(${OSAL_SOURCE_DIR}/../obdh_v0_defs/)

# FBV 2024-02-28 The include_directories below is only for debugging and should removed from final build.
include_directories(${CFE_SOURCE_DIR}/modules/es/fsw/src)
include_directories(${CFE_SOURCE_DIR}/modules/core_private/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/msg/fsw/inc)
include_directories(${CFE_SOURCE_DIR}/modules/core_api/fsw/inc)