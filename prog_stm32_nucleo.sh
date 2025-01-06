#!/bin/bash

THIS_SCRIPT=${BASH_SOURCE[0]}
THIS_SCRIPT_FULLNAME=$(realpath $THIS_SCRIPT)
THIS_SCRIPT=$(basename ${THIS_SCRIPT_FULLNAME})
ROOT_DIR=$(dirname $THIS_SCRIPT_FULLNAME)

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    THIS_BASH_SCRIPT_SOURCED=0
    echo "${THIS_SCRIPT}:RUNNING $THIS_SCRIPT_FULLNAME"
else
    THIS_BASH_SCRIPT_SOURCED=1
    echo "${THIS_SCRIPT}:SOURCING $THIS_SCRIPT_FULLNAME"
fi

echo "${THIS_SCRIPT}:ROOT $ROOT_DIR"

SERIAL_PORT=/dev/ttyACM0

if [ ! -c $SERIAL_PORT ]; then
    echo "Serial port device ${SERIAL_PORT} not found."
    exit -1
fi

DEVICE_PATH=$(udevadm info -q path -n ${SERIAL_PORT})
DEVICE_SERIAL=$(udevadm info -q property -p ${DEVICE_PATH} | grep ID_SERIAL_SHORT | cut -d "=" -f 2)

if [ -z $DEVICE_SERIAL ]; then
    echo "Failed udevadm. Exit status ${rc}"
    if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
        exit ${rc}
    else
        return ${rc}
    fi
fi


echo "Serial port device is ${SERIAL_PORT}."
echo "Device path is ${DEVICE_PATH}."
echo "Device serial is ${DEVICE_SERIAL}."

openocd -s /usr/share/openocd/scripts/  --file board/stm32f7discovery.cfg --command "hla_serial ${DEVICE_SERIAL}; program ./core-cpu1 verify reset exit"
rc=$?

if [ ! ${rc} -eq 0 ]; then
    echo "Failed openocd. Exit status ${rc}"

    if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
        exit ${rc}
    else
        return ${rc}
    fi
fi

################################################
################################################
################################################
if [ ${THIS_BASH_SCRIPT_SOURCED} -eq 0 ]; then
    exit ${rc}
else
    return ${rc}
fi
