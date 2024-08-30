#!/bin/bash

modinfo -F version nvidia 

sudo akmods --force 

sudo dracut --force 

sudo dnf copr enable sunwire/envycontrol -y

sudo dnf install python3-envycontrol -y



