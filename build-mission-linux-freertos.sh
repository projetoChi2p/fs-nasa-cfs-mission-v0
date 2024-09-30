#!/bin/bash

# Make file variables:

MAKEFILE=Makefile
MISSIONCONFIG="obdh_v0"

JOBS=""
SIMULATION="i386-freertos-linux"

# ``SIMULATION``: If set, this will override the architecture(s) specified 
# in the targets file.

OUTDIR=build_${MISSIONCONFIG}_${SIMULATION} # defaults to 'build'

#DESTDIR defaults to ${OUTDIR}
#INSTALLPREFIX defaults to ${DESTDIR}/exe
#BUILDTYPE defaults to "debug"
#ARCH defaults to 'native/default_cpu1'
BUILDTYPE=release

export HOSTNAME="inf.ufrgs.br"
export USER="fbenevenuti"

#GCC_ROOT=/media/fabiob/portdev/toolchain_pc/gcc-12.2.0-multilib
#LD_LIBRARY_PATH=${GCC_PATH}/
#PATH=${GCC_ROOT}/bin:$PATH

THIS_SCRIPT=${BASH_SOURCE[0]}
THIS_SCRIPT_FULLNAME=$(realpath $THIS_SCRIPT)
THIS_SCRIPT=$(basename ${THIS_SCRIPT_FULLNAME})
ROOT_DIR=$(dirname $THIS_SCRIPT_FULLNAME)

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "${THIS_SCRIPT}:RUNNING $THIS_SCRIPT_FULLNAME"
    THIS_BASH_SCRIPT_SOURCED=0
else
    echo "${THIS_SCRIPT}:SOURCING $THIS_SCRIPT_FULLNAME"
    THIS_BASH_SCRIPT_SOURCED=1
fi


#!/bin/bash

# Make file variables:

# cFS build considers a multi-target/board/cpu complex system
# including one node with is the 'host' unit of the 'native' kind
# to which tools are built.
# for any other nodes, of different kind determined by the toolchain
# name, e.g. 'arm-cortexa8_neon-linux-gnueabi', a different set of
# cFS modules and apps can be built and deployed to be integrated
# over the bus network
# These node can be homogeneous or heretogeneous cores on a single or 
# on different SoCs.

# Make/CMake build will iterate over host and all other target CPUs
# build its respective software components.

# For this specific build, we will have a single CPU which is the
# 'native' host x64 computer running Linux.

# cFE top CMake variables
#${TARGETSYSTEM} represents the system type, matching the toolchain.
#MISSION_SOURCE_DIR defaults to cFE parent dir, e.g. cFS repo root dir
#MISSIONCONFIG may be autodetected
# CMake cFE will scan $MISSION_SOURCE_DIR for any path ending with _defs and, if found, will extract mission name from path
# For instance, given cFS repo top path .../nasa-cfs-2023-08-22-dev/obdh_v0_defs MISSIONCONFIG becomes 'obdh_v0'
#Then
#... MISSION_DEFS <= ${MISSION_SOURCE_DIR}/${MISSIONCONFIG}_defs
#MISSION_DEFS can be populated from .../cfe/cmake/sample_defs

# ${MISSION_DEFS}/targets.cmake                            ---> (mandatory) 
# ${MISSION_DEFS}/global_build_options.cmake               ---> (OPTIONAL)  global-scope build customization
# ${MISSION_DEFS}/arch_build_custom.cmake                  ---> (OPTIONAL)  all cpus/nodes common customization
# ${MISSION_DEFS}/arch_build_custom_${TARGETSYSTEM}.cmake  ---> (OPTIONAL)  ${TARGETSYSTEM} cpus/nodes specific customization
# ${MISSION_DEFS}/mission_build_custom.cmake               ---> (OPTIONAL)  host/native??? customization

THIS_SCRIPT=${BASH_SOURCE[0]}
THIS_SCRIPT_FULLNAME=$(realpath $THIS_SCRIPT)
THIS_SCRIPT=$(basename ${THIS_SCRIPT_FULLNAME})
ROOT_DIR=$(dirname $THIS_SCRIPT_FULLNAME)
cp cfe/cmake/Makefile.sample Makefile

#(return 0 2>/dev/null) && THIS_BASH_SCRIPT_SOURCED=1 || THIS_BASH_SCRIPT_SOURCED=0

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    THIS_BASH_SCRIPT_SOURCED=0
else
    THIS_BASH_SCRIPT_SOURCED=1
fi

echo "${THIS_SCRIPT}:RUNNING $THIS_SCRIPT_FULLNAME"

cd ${ROOT_DIR}



if true; then
    #mkdir -p ${ROOT_DIR}/${OUTDIR}
    #cd ${ROOT_DIR}/${OUTDIR}
    rm -rf ${ROOT_DIR}/${OUTDIR}
    #cd ${ROOT_DIR}


    # Run CMake to prepare target build/makefiles
    # It uses a 'Makefile' at top cFS dir which is populated form 'cfe/cmake/Makefile.sample'
    make \
    MISSIONCONFIG=${MISSIONCONFIG}      \
    BUILDTYPE=${BUILDTYPE}              \
    SIMULATION=${SIMULATION}            \
    O=${ROOT_DIR}/${OUTDIR}             \
    ${JOBS} -f ${MAKEFILE} prep

    rc=$?

    if [ ! ${rc} -eq 0 ]; then
        echo "Failed make prep. Exit status ${rc}"

        if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
            exit ${rc}
        else
            return ${rc}
        fi
    fi
fi


make \
    SIMULATION=${SIMULATION}            \
    O=${ROOT_DIR}/${OUTDIR}             \
    ${JOBS} -f ${MAKEFILE} all

rc=$?

if [ ! ${rc} -eq 0 ]; then
    echo "Failed make build. Exit status ${rc}"

    if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
        exit ${rc}
    else
        return ${rc}
    fi
fi

echo Continue

if false; then
    make \
        SIMULATION=${SIMULATION}            \
        O=${ROOT_DIR}/${OUTDIR}             \
        ${JOBS} -f ${MAKEFILE} install

    rc=$?

    if [ ! ${rc} -eq 0 ]; then
        echo "Failed make build. Exit status ${rc}"

        if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
            exit ${rc}
        else
            return ${rc}
        fi
    fi
fi

# fs can crash on setschedparam() inside OS_Posix_TaskAPI_Impl_Init()
# may need to run as root/sudo or tweak /etc/security/limits.conf, e.g. 
#fabiob           hard    rtprio          99
#fabiob           hard    priority        99
#fabiob           soft    rtprio          99
#fabiob           soft    priority        99
#$ ulimit -Ha
#$ ulimit -Sa

# fs can crash in OS_QueueCreate(), possibly due to queue size 
# exceeding /proc/sys/fs/mqueue/msg_max
# may need to tweak /etc/sysctl.conf
# fs.mqueue.msg_max = 100

if false; then

    make \
        SIMULATION=${SIMULATION}            \
        O=${ROOT_DIR}/${OUTDIR}             \
        ${JOBS} -f ${MAKEFILE} doc

    rc=$?

    if [ ! ${rc} -eq 0 ]; then
        echo "Failed make build. Exit status ${rc}"

        if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
            exit ${rc}
        else
            return ${rc}
        fi
    fi

fi
