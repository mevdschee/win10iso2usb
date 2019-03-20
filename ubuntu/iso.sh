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
CHOICE=$(dialog --clear --backtitle "win10iso2usb" --title "Step 1/3: Select Windows ISO" --menu "Choose a file:" $HEIGHT $WIDTH $CHOICE_HEIGHT "${ISOFILES[@]}" 2>&1 >$(tty))

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
CHOICE=$(dialog --clear --backtitle "win10iso2usb" --title "Step 2/3: Select USB drive" --menu "Choose a drive:" $HEIGHT $WIDTH $CHOICE_HEIGHT "${USBDRIVES[@]}" 2>&1 >$(tty))

if [ -z $CHOICE ]; then
   clear
   echo Cancelled
   exit 0
fi
clear
(( ITEM=($CHOICE * 2) ))
USBDRIVE=${USBDRIVES[ITEM]}

echo $ISOFILE
echo $USBDRIVE


# Zap disk
echo "Zapping disk..."
sudo sgdisk --zap-all /dev/sdX
# Create a FAT32 partition and set 'msftdata' flag
sudo parted /dev/sdX -s mklabel gpt
echo "Creating /dev/sdX1..."
sudo parted /dev/sdX -s mkpart primary fat32 2048s 100%
sudo parted /dev/sdX -s set 1 msftdata on
# Format the partition as fat32
echo "Formatting the ESP partition as fat32..."
yes | sudo mkfs.fat -F32 /dev/sdX1

