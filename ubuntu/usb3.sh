#!/bin/bash

# source: https://unix.stackexchange.com/questions/40143/how-to-know-if-dev-sdx-is-a-connected-usb-or-hdd

lsblk --nodeps --output NAME,TRAN,RM



# https://unix.stackexchange.com/questions/70738/what-is-the-fastest-way-to-extract-an-iso

sudo apt-get install p7zip-full

mkdir win10

7z x ~/Downloads/Win10_1809Oct_EnglishInternational_x64.iso -owin10

