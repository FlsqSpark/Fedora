#!/bin/bash

sudo dnf install gcc kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 

echo "Wait 5 minutes for the drivers to finish installing, then run nvidia3.sh"

