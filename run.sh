#!/usr/bin/env bash

# for ethernet interface
ethernet_interface=$(nmcli -t -f TYPE,DEVICE connection show --active | grep 802-3-ethernet | cut -d: -f2)
export NETWORK_INTERFACE=$ethernet_interface

tmuxp load launch_robots.yml