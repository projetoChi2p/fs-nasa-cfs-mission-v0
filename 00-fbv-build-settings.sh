#!/bin/bash

# Make file variables:

MAKEFILE=Makefile
MISSIONCONFIG="obdh_v0"

JOBS="-j 6"
if [ 1 == 0 ]; then
SIMULATION="i386-freertos-linux"
else
SIMULATION="nucleo-f767-freertos"
export PATH=/opt/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi/bin/:${PATH}
fi

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
