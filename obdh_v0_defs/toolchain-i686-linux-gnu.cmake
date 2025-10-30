# This example toolchain file describes the cross compiler to use for
# the target architecture indicated in the configuration file.

# Basic cross system configuration
SET(CMAKE_SYSTEM_NAME           Linux)
SET(CMAKE_SYSTEM_VERSION        1)
SET(CMAKE_SYSTEM_PROCESSOR      i686)

# Specify the cross compiler executables
# Typically these would be installed in a home directory or somewhere
# in /opt.  However in this example the system compiler is used.
SET(CMAKE_C_COMPILER            "/usr/bin/gcc")
SET(CMAKE_CXX_COMPILER          "/usr/bin/g++")

# Configure the find commands
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM   NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY   NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE   NEVER)

set(COMPILER_LINKER_OPTION_PREFIX "-Wl,")
set(START_WHOLE_ARCHIVE "--whole-archive")
set(STOP_WHOLE_ARCHIVE  "--no-whole-archive")
set(START_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${START_WHOLE_ARCHIVE}")
set(STOP_WHOLE_ARCHIVE "${COMPILER_LINKER_OPTION_PREFIX}${STOP_WHOLE_ARCHIVE}")

# These variable settings are specific to cFE/OSAL and determines which 
# abstraction layers are built when using this toolchain
SET(CFE_SYSTEM_PSPNAME      "pc-linux")
SET(OSAL_SYSTEM_BSPTYPE     "generic-linux")
SET(OSAL_SYSTEM_OSTYPE      "posix")

GET_FILENAME_COMPONENT(MY_MISSION_DEFS_DIR "${CMAKE_CURRENT_LIST_FILE}"     DIRECTORY)
GET_FILENAME_COMPONENT(TOP_PROJECT_DIR     "${MY_MISSION_DEFS_DIR}/../"     REALPATH )
GET_FILENAME_COMPONENT(OSAL_SOURCE_DIR     "${TOP_PROJECT_DIR}/osal"        REALPATH )


# OSAL
include_directories(${OSAL_SOURCE_DIR}/src/os/shared/inc)
include_directories(${OSAL_SOURCE_DIR}/src/os/posix/inc)
