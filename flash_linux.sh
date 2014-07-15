#!/bin/bash

# Colors
blue=$(tput setaf 4)
red=$(tput setaf 1)
white=$(tput setaf 7)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
underline=$(tput smul)
normal=$(tput sgr0)

# Update
B2G_OBJDIR="update/gecko/b2g"
GAIA_INSTALL_PARENT="/system/b2g"
files_dir="files/"
B2G_PREF_DIR=/system/b2g/defaults/pref

function pause(){
   read -p "$*"
}

function channel_ota {
    ./adb remount
    ./adb push ${files_dir}/updates.js $B2G_PREF_DIR/updates.js
    ./adb reboot
}

function update_channel{
    echo ""
    echo "We are going to change the update channel,"
    echo "so, in the future you will receive updates"
    echo "without flash every time."
    sleep 2
    echo "Are you ready?: "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) channel_ota; break;;
            No ) echo "Aborted"; break;;
        esac
    done
}

function adb_hamachi_root() {
    echo ""
    rm -r boot-init
    ./adb shell "rm /sdcard/fxosbuilds/newboot.img"
    echo "Creating a copy of boot.img"
    ./adb shell echo 'cat /dev/mtd/mtd1 > /sdcard/fxosbuilds/boot.img' \| su
    echo "building the workspace"
    mkdir boot-init
    cp ${files_dir}mkbootfs boot-init/mkbootfs
    cp ${files_dir}mkbootimg boot-init/mkbootimg
    cp ${files_dir}split_bootimg.pl boot-init/split_bootimg.pl
    cp ${files_dir}hamachi-default.prop boot-init/default.prop
    cd boot-init
    echo "Copying your boot.img copy"
    ./adb pull /sdcard/fxosbuilds/boot.img
    ./split_bootimg.pl boot.img
    mkdir initrd
    cd initrd 
    mv ../boot.img-ramdisk.gz initrd.gz
    echo "Boot change process"
    gunzip initrd.gz
    cpio -id < initrd
    rm default.prop
    echo "New default.prop"
    cd ..
    mv mkbootfs initrd/mkbootfs
    mv default.prop initrd/default.prop
    cd initrd
    ./mkbootfs . | gzip > ../newinitramfs.cpio.gz
    cd ..
    cd ..
    ./mkbootimg --kernel zImage --ramdisk newinitramfs.cpio.gz --base 0x200000 --cmdline 'androidboot.hardware=hamachi' -o newboot.img
    ./adb push boot-init/newboot.img /sdcard/fxosbuilds/newboot.img
    ./adb shell echo 'flash_image boot /sdcard/fxosbuilds/newboot.img' \| su
    echo "Success!"
    sleep 3
}

function adb_root_select() {
    echo "${green} "
    echo " ............................................................."
    echo "${cyan} "
    echo " "
    echo " Connect your phone to USB, then:"
    echo " "
    echo " Settings -> Device information -> More Information"
    echo " -> Developer and enable 'Remote debugging'"
    echo "${green} "
    echo " ............................................................."
    echo "${normal} "
    PS3='Are you ready to start adb root process?: '
    options=("Yes" "No" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                adb_hamachi_root
                ;;
            "No")
                echo "Carefull! you need to have root access to update"
                main
                ;;
            "Back menu")
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function root_hamachi_ready() {
    echo ""
    echo "Rebooting the device"
    ./adb reboot bootloader
    echo "Flashing the new recovery"
    ./${files_dir}fastboot flash recovery root/hamachi_clockworkmod_recovery.img
    echo ""
    echo "Now power off your device, and retire the battery for 5 seconds, be sure"
    echo "of your device is pluged to your computer."
    echo ""
    pause 'Press [Enter] key to continue...'
    echo ""
    echo "Waiting for device"
    ./adb wait-for-device
    echo "Push the SU binary packagefor root access"
    ./adb shell "rm /sdcard/fxosbuilds/update-alcatel-su.zip"
    ./adb shell mkdir /sdcard/fxosbuilds
    ./adb push root/root_alcatel-signed.zip /sdcard/fxosbuilds/update-alcatel-su.zip
    echo "Rebooting on recovery mode"
    ./adb reboot recovery
    echo "Now you need to install first the update-alcatel-su.zip package"
    echo ""
    pause "Press [Enter] when you finished it to continue..."
    echo ""
    echo "Waiting for device"
    ./adb wait-for-device
    # We need to find a way to check if device is rooted
    echo "Rooted"
    sleep 1
    echo ""
    echo "Now we are going to get adb root access"
    echo ""
    adb_hamachi_root
    echo "Rebooting device"
    ./adb reboot
    ./adb wait-for-device
    echo "Returning to main menu"
    sleep 2
    main
}

function root_hamachi() {
    echo "   "
    echo "               ** IMPORTANT **"
    echo "   "
    echo "   Connect your phone to USB, then:"
    echo "   "
    echo "   Settings -> Device information -> More Information"
    echo "   -> Developer and enable 'Remote debugging'"
    echo "   "
    echo "Are you sure you want to continue?"
    echo "   "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_hamachi_ready; break;;
            No ) echo "You are not sure, come back when you will :)"; main; break;;
        esac
    done
}

function delete_extra_gecko_files_on_device() {
    files_to_remove="$(cat <(ls $B2G_OBJDIR) <(./adb shell "ls /system/b2g" | tr -d '\r') | sort | uniq -u)"
    if [ "$files_to_remove" != "" ]; then
        ./adb shell "cd /system/b2g && rm $files_to_remove" > /dev/null
    fi
    return 0
}

function verify_update() {
    echo "Was your device updated?"
    PS3='?: '
    options=("Yes" "No" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                echo "Nice"
                main
                break;;
            "No")
                echo "Please, contact us. We will look what we can do for you."
                sleep 2
                main
                break;;
            *) echo "** Invalid option **";;
        esac
    done
}

function go_update() {
    # Working on gecko
    echo "Flashing Gecko"
    echo " "
    ./adb wait-for-device
    ./adb shell stop b2g &&
    ./adb remount &&
    delete_extra_gecko_files_on_device &&
    ./adb push $B2G_OBJDIR /system/b2g &&
    echo " "
    echo "Restarting B2G ...." &&
    echo " "
    ./adb shell start b2g

    # Working on gaia
    echo "Flashing Gaia"
    echo " "
    ./adb shell stop b2g
    for FILE in `./adb shell ls /data/local | tr -d '\r'`;
    do
        if [ $FILE != 'tmp' ]; then
            ./adb shell rm -r /data/local/$FILE
        fi
    done
    ./adb shell rm -r /cache/*
    ./adb shell rm -r /data/b2g/*
    ./adb shell rm -r /data/local/webapps
    ./adb remount
    ./adb shell rm -r /system/b2g/webapps

    echo " "
    echo "Installing Gaia"
    ./adb start-server
    ./adb shell stop b2g 
    ./adb shell rm -r /cache/*
    echo ""
    echo "Remounting partition to start the gaia install"
    ./adb remount
    cd update/gaia
    python ../install-gaia.py "../adb" ${GAIA_INSTALL_PARENT}
    cd ..
    echo ""
    echo "Gaia installed"
    echo ""
    echo "Starting system"
    cd ..
    ./adb shell start b2g
    echo "..."
    # install default data
    ./adb shell stop b2g
    echo "......"
    ./adb remount
    echo "........."
    ./adb push update/gaia/profile/settings.json /system/b2g/defaults/settings.json
    #ifdef CONTACTS_PATH
    #    ./adb push profile/contacts.json /system/b2g/defaults/contacts.json
    #else
    echo "............"
    ./adb shell rm /system/b2g/defaults/contacts.json
    #endif
    echo "${green}DONE!${normal}"
    ./adb shell start b2g
    echo " "
    ./adb reboot
    ./adb wait-for-device
    update_channel
    sleep 2
    verify_update
}

function update_accepted() {
    echo "${green} "
    echo " ............................................................."
    echo "${cyan} "
    echo " Is your device rooted?"
    echo " "
    echo " "
    echo " Connect your phone to USB, then:"
    echo " "
    echo " Settings -> Device information -> More Information"
    echo " -> Developer and enable 'Remote debugging'"
    echo "${green} "
    echo " ............................................................."
    echo "${normal} "
    PS3='Are you ready?: '
    options=("Yes" "No" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                echo "The update process will start in 5 seconds"
                sleep 5
                go_update
                ;;
            "No")
                echo "You need to be root first to update"
                sleep 2
                root
                ;;
            "Back menu")
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function root_accepted() {
    echo "${green} "
    echo " ............................................................."
    echo "${cyan} "
    echo " Which is your device?"
    echo " "
    echo " "
    echo " Connect your phone to USB, then:"
    echo " "
    echo " Settings -> Device information -> More Information"
    echo " -> Developer and enable 'Remote debugging'"
    echo "${green} "
    echo " ............................................................."
    echo "${normal} "
    PS3='Are you ready?: '
    options=("Yes" "No" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                root_hamachi
                ;;
            "No")
                echo "Back when you are ready"
                ;;
            "Back menu")
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function root() {
    echo "   "
    echo "${green}       ............................................................."
    echo "${cyan}   "
    echo "                              Disclaimer"
    echo "   "
    echo "             By downloading and installing the root you accept"
    echo "             that your warranty is void and we are not in no way"
    echo "             responsible for any damage or data loss may incur."
    echo "  "
    echo "             We are not responsible for bricked devices, dead SD"
    echo "             cards, or you getting fired because the alarm app" 
    echo "             failed. Please do some research if you have any"
    echo "             concerns about this update before flashing it."
    echo "   "
    echo "${green}       ............................................................."
    echo "${normal}   "
    PS3='Do you agree?: '
    options=("Yes" "No" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                root_accepted
                ;;
            "No")
                echo "** You don't agree **";
                sleep 3
                main
                ;;
            "Quit")
                exit 0
                break
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function update() {
    echo "   "
    echo "${green}       ............................................................."
    echo "${cyan}   "
    echo "                              Disclaimer"
    echo "   "
    echo "             By downloading and installing the update you accept"
    echo "             that your warranty is void and we are not in no way"
    echo "             responsible for any damage or data loss may incur."
    echo "  "
    echo "             We are not responsible for bricked devices, dead SD"
    echo "             cards, or you getting fired because the alarm app" 
    echo "             failed. Please do some research if you have any"
    echo "             concerns about this update before flashing it."
    echo "   "
    echo "${green}       ............................................................."
    echo "${normal}   "
    PS3='Do you agree?: '
    options=("Yes" "No" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                update_accepted
                ;;
            "No")
                echo "** You don't agree **";
                sleep 3
                main
                ;;
            "Quit")
                exit 0
                break
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function rules {
    echo ""
    echo "We need the password you use with sudo,"
    echo "to copy the rules in your system."
    echo ""
    echo "So, be sure to provide the pass."
    sleep 3
    echo ""
    echo "Removing old rules in the system"
    sudo rm /etc/udev/rules.d/51-android.rules
    echo ""
    echo "Copying template file to the udev folder..."
    sudo cp ${files_dir}51-android.rules /etc/udev/rules.d/
    echo ""
    echo "Applying permissions"
    sudo chmod a+r /etc/udev/rules.d/51-android.rules
}

function option_two() {
    echo "${green} "
    echo " ............................................................."
    echo "${cyan} "
    echo " What you what to do?"
    echo " "
    echo "${green} "
    echo " ............................................................."
    echo "${normal} "
    PS3='#?: '
    options=("Root" "ADB root" "Update" "Change update channel" "Android rules" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "Root")
                root
                ;;
            "ADB root")
                adb_root_select
                ;;
            "Update")
                update
                ;;
            "Change update channel")
                update_channel
                ;;
            "Android rules")
                rules
                ;;
            "Back menu")
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function option_one {
    rules
    root
    update
}

function main() {
    echo ""
    echo "${green} ............................................................."
    echo " "
    echo " "
    echo " "
    echo " ${cyan} ${cyan}FirefoxOS Builds installer "
    echo " "
    echo " "
    echo " "
    echo "${green} ............................................................."
    echo ""
    echo ""
    echo " ${normal} Welcome to the FirefoxOS Builds installer. Please enter the number of"
    echo " your selection & follow the prompts."
    echo ""
    echo ""
    echo " 1) Update your device"
    echo " 2) Advanced"
    echo " 3) Exit"
    echo ""
    read mainmen
    if [ "$mainmen" == 1 ] ; then
        option_one
    elif [ "$mainmen" == 2 ] ; then
        option_two
    elif [ "$mainmen" == 3 ] ; then
        echo ""
        echo " ------------------------------------------"
        echo " Exiting FirefoxOS Builds installer "
        sleep 2
        exit 0
    elif [ "$mainmen" != 1 ] && [ "$mainmen" != 2 ]; then
        echo ""
        echo ""
        echo " Enter a valid number "
        echo ""
        sleep 2
        main
    fi
}

main