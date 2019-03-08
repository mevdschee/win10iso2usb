#!/bin/bash


getDeviceType() {
	typeset deviceName=/sys/block/${1#/dev/}
	typeset deviceType=$(udevadm info --query=property --path="$deviceName" | grep -Po 'ID_BUS=\K\w+')
	echo "$deviceType"
}

typeset -a devices
typeset device
mapfile -t devices < <(lsblk -o NAME,TYPE | grep --color=never -oP '^\K\w+(?=\s+disk$)')
USBKEYS=()
for device in "${devices[@]}"; do
    if [ "$(getDeviceType "/dev/$device")" == "usb" ] || [ "$disableUSBCheck" == 'true' ]; then
        USBKEYS+=("$device")
    fi
done

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
