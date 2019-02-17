#!/bin/bash

# source: https://unix.stackexchange.com/questions/60299/how-to-determine-which-sd-is-usb

export USBKEYS=($(
    grep -Hv ^0$ /sys/block/*/removable |
    sed s/removable:.*$/device\\/uevent/ |
    xargs grep -H ^DRIVER=sd |
    sed s/device.uevent.*$/size/ |
    xargs grep -Hv ^0$ |
    cut -d / -f 4
))

export STICK
case ${#USBKEYS[@]} in
    0 ) echo No USB Stick found; exit 0 ;;
    * )
    STICK=$(
    bash -c "$(
        echo -n  dialog --menu \
            \"Choose wich USB stick has to be installed\" 22 76 17;
        for dev in ${USBKEYS[@]} ;do
            echo -n \ $dev \"$(
                sed -e s/\ *$//g </sys/block/$dev/device/model
                )\" ;
            done
        )" 2>&1 >/dev/tty
    )
    ;;
esac

[ "$STICK" ] || exit 0

echo $STICK...
