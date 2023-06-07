#!/bin/bash

set -e # -e  Exit this script immediately if a command exits with a non-zero status.
#set -x # -x  Print commands and their arguments as they are executed.

export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program\ Files/Oracle/VirtualBox/"

vagrant up
