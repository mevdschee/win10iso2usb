#! /bin/bash

# Steps:

# 1/5 Choose Windows ISO file
# 2/5 Choose USB drive to erase
# 3/5 Confirm erase and write
# 4/5 Compress install.wim (wimtools/wimlib)
# 5/5 Partition and copy (sfdisk)

#dialog manual: http://www.unixcl.com/2009/12/linux-dialog-utility-short-tutorial.html

#show progress: https://www.tecmint.com/monitor-copy-backup-tar-progress-in-linux-using-pv-command/

#source: https://stackoverflow.com/questions/4889187/dynamic-dialog-menu-box-in-bash

#usage: Dynamic_Menu.bash /home/user/target_directory

declare -a ISOFILES

i=1 #Index counter for adding to ISOFILES
j=1 #Option menu value generator

while read line
do
   ISOFILES[ $i ]=$j
   (( j++ ))
   ISOFILES[ ($i + 1) ]=$line
   (( i=($i+2) ))
done < <(locate "*.iso") #consume file path provided as argument
#done < <(find $1 -type f -name "*.iso") #consume file path provided as argument

if [ -z ${ISOFILES[@]} ]; then
   clear
   echo No ISO files found
   exit 0
fi

if [ -z ${ISOFILES[@]} ]; then
   clear
   echo "No ISO files found. Exiting."
   exit 0
fi

#Define parameters for menu
HEIGHT=20
WIDTH=76
CHOICE_HEIGHT=($HEIGHT - 4)

#Build the menu with variables & dynamic content
CHOICE=$(dialog --backtitle "win10iso2usb" --title "Step 1/3: Select Windows ISO" --menu "\n Choose a file:" $HEIGHT $WIDTH $CHOICE_HEIGHT "${ISOFILES[@]}" 2>&1 >$(tty))

if [ -z $CHOICE ]; then
   clear
   echo Cancelled
   exit 0
fi
(( ITEM=($CHOICE * 2) ))
ISOFILE=${ISOFILES[ITEM]}

declare -a USBDRIVES

i=1 #Index counter for adding to USBDRIVES
j=1 #Option menu value generator

while read line
do
   USBDRIVES[ $i ]=$j
   (( j++ ))
   USBDRIVES[ ($i + 1) ]=$line
   (( i=($i+2) ))
done < <(lsblk --nodeps -n --output TRAN,NAME,SIZE,VENDOR,MODEL | tr -s ' ' | sed 's/ /: /2' | cut '-d ' '-f2-')
#done < <(lsblk --nodeps -n --output TRAN,NAME,SIZE,VENDOR,MODEL | grep '^usb' | tr -s ' ' | sed 's/ /: /2' | cut '-d ' '-f2-')

if [ -z ${USBDRIVES[@]} ]; then
   clear
   echo No USB drives found
   exit 0
fi

if [ -z ${USBDRIVES[@]} ]; then
   clear
   echo "No USB drives found. Exiting."
   exit 0
fi

#Build the menu with variables & dynamic content
CHOICE=$(dialog --backtitle "win10iso2usb" --title "Step 2/3: Select USB drive" --menu "\n Choose a drive:" $HEIGHT $WIDTH $CHOICE_HEIGHT "${USBDRIVES[@]}" 2>&1 >$(tty))

if [ -z $CHOICE ]; then
   clear
   echo Cancelled
   exit 0
fi
clear
(( ITEM=($CHOICE * 2) ))
USBDRIVE=${USBDRIVES[ITEM]}


dialog --backtitle "win10iso2usb" --title "Step 3/3: Confirm selection" --yesno "\n You are about to write ISO file:\n\n $ISOFILE\n\n to USB drive:\n\n $USBDRIVE\n\n DELETING ALL CONTENTS ON THE USB DRIVE\n\n Are you sure?" $HEIGHT $WIDTH 2>&1 >$(tty)

if [ $? -gt 0 ]; then
   clear
   echo Cancelled
   exit 0
fi

#DISK=$(echo $USBDRIVE | cut -d":" -f1)
DISK=sdX

# Zapping disk /dev/sdX
# Create a FAT32 partition and set 'msftdata' flag
dialog --backtitle "win10iso2usb" --title "Writing" --infobox "\n  Step 1/5: Zapping disk /dev/$DISK ..." 5 75 ; sudo sgdisk --zap-all /dev/$DISK
dialog --backtitle "win10iso2usb" --title "Writing" --infobox "\n  Step 2/5: Initialize GPT partition table on /dev/$DISK ..." 5 75 ; sudo parted /dev/$DISK -s mklabel gpt
dialog --backtitle "win10iso2usb" --title "Writing" --infobox "\n  Step 3/5: Create a FAT32 partition on /dev/$DISK ..." 5 75 ; sudo parted /dev/$DISK -s mkpart primary fat32 2048s 100%
dialog --backtitle "win10iso2usb" --title "Writing" --infobox "\n  Step 4/5: Set 'msftdata' flag on partition /dev/${DISK}1 ..." 5 75 ; sudo parted /dev/$DISK -s set 1 msftdata on
dialog --backtitle "win10iso2usb" --title "Writing" --infobox "\n  Step 5/5: Formatting partition /dev/${DISK}1 as FAT32..." 5 75 ; yes | sudo mkfs.fat -F32 /dev/${DISK}1
dialog --backtitle "win10iso2usb" --title "Writing" --infobox "\n  Done ..." 5 75 ; sleep 0.5
clear

# compress using wimlib
# copy to usb

echo Done

