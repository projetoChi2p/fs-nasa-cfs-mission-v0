#!/bin/bash

openocd -s /usr/share/openocd/scripts/ --file board/stm32f7discovery.cfg --command "hla_serial 066FFF524881774867214116; program build_obdh_v0_nucleo-f767-freertos/nucleo-f767-freertos/default_cpu1/cpu1/core-cpu1 verify reset exit"
