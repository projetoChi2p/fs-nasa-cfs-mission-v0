
# The OSAL customization ..._osconfig.cmake file can be named after default, a cpu name or a toolchain name, for instance:
# i386-freertos-linux_osconfig.cmake
# default_osconfig.cmake
# cpu1_osconfig.cmake

message("+++ Inside list cmake ${CMAKE_CURRENT_LIST_FILE}.")


# This mission is using less than 20 tasks, incluind non-osal pure FreeRTOS tasks
set(OSAL_CONFIG_MAX_TASKS                 20 CACHE STRING "Target overriden maximum number of tasks to support" FORCE)

# This mission is using up to 2 filesystems
set(OSAL_CONFIG_MAX_FILE_SYSTEMS           2 CACHE STRING "Target overriden maximum number of file systems to support" FORCE)

# This mission is using up to 1 file
set(OSAL_CONFIG_MAX_NUM_OPEN_FILES         2 CACHE STRING "Target overriden maximum number of open files to support" FORCE)

# This mission is using up to 1 dir
set(OSAL_CONFIG_MAX_NUM_OPEN_DIRS          2 CACHE STRING "Target overriden maximum number of open directories to support" FORCE)


message("+++ Leaving list cmake ${CMAKE_CURRENT_LIST_FILE}.")
