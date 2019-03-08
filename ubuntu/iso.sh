#! /bin/bash

#source: https://stackoverflow.com/questions/4889187/dynamic-dialog-menu-box-in-bash

#usage: Dynamic_Menu.bash /home/user/target_directory

declare -a array

i=1 #Index counter for adding to array
j=1 #Option menu value generator

while read line
do
   array[ $i ]=$j
   (( j++ ))
   array[ ($i + 1) ]=$line
   (( i=($i+2) ))
done < <(find $1 -type f -name "*.iso") #consume file path provided as argument
#done < <(locate "*.iso") #consume file path provided as argument

#Define parameters for menu
HEIGHT=20
WIDTH=76
CHOICE_HEIGHT=($HEIGHT - 4)

#Build the menu with variables & dynamic content
CHOICE=$(dialog --clear --backtitle "win10iso2usb" --title "Step 1/3: Select Windows ISO" --menu "Choose a file:" $HEIGHT $WIDTH $CHOICE_HEIGHT "${array[@]}" 2>&1 >$(tty))

if [ -z $CHOICE ]; then
   clear
   exit 0
fi
clear
(( ITEM=($CHOICE * 2) ))
FILE=${array[ITEM]}
echo $FILE
