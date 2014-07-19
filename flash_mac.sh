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
files_dir="files/"
B2G_PREF_DIR=/system/b2g/defaults/pref

function pause(){
   read -p "$*"
}

function channel_ota {
    echo "Remounting..."
    ./adb.mac shell echo "mount -o rw,remount /system" \| su
    echo "Removing old channel"
    ./adb.mac shell "rm /system/b2g/defaults/pref/updates.js"
    echo "Pushing new OTA channel"
    ./adb.mac push ${files_dir}/updates.js $B2G_PREF_DIR/updates.js
    echo "Rebooting-..."
    ./adb.mac reboot
}

function update_channel {
    echo ""
    echo "We are going to change the update channel,"
    echo "so, in the future you will receive updates"
    echo "without flash every time."
    sleep 2
    echo "Are you ready?: "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) channel_ota;;
            No ) echo "Aborted";;
        esac
    done
}

function verify_root() {
    echo ""
    echo "Was your device rooted?"
    PS3='?: '
    options=("Yes" "No")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                echo "Nice"
                ;;
            "No")
                echo "Please, contact us. We will look what we can do for you."
                sleep 2
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function root_hamachi_ready() {
    echo ""
    echo "Rebooting the device"
    ./adb.mac reboot bootloader
    echo "Flashing the new recovery"
    ./fastboot.mac flash recovery root/hamachi_clockworkmod_recovery.img
    echo ""
    echo "Now power off your device, and retire the battery for 5 seconds, be sure"
    echo "of your device is pluged to your computer."
    echo ""
    pause 'Press ${red}[Enter]${normal} key to continue...'
    echo ""
    echo "Waiting for device"
    ./adb.mac wait-for-device
    echo "Push the ${green}SU${normal} binary package for root access"
    ./adb.mac shell "rm /sdcard/fxosbuilds/update-alcatel-su.zip"
    ./adb.mac shell mkdir /sdcard/fxosbuilds
    ./adb.mac push root/root_alcatel-signed.zip /sdcard/fxosbuilds/update-alcatel-su.zip
    echo "Rebooting on recovery mode"
    ./adb.mac reboot recovery
    echo "Now you need to install first the update-alcatel-su.zip package"
    echo ""
    pause "Press ${red}[Enter]${normal} when you finished it to continue..."
    echo ""
    echo "Waiting for device"
    ./adb.mac wait-for-device
    # We need to find a way to check if device is rooted
    echo "Rooted"
    sleep 1
    echo ""
    echo "Rebooting device"
    ./adb.mac reboot
    ./adb.mac wait-for-device
    verify_root
}

function root_hamachi() {
    echo "   "
    echo "                         ${red}** IMPORTANT **${normal}"
    echo "   "
    echo "              Connect your phone to USB, then:"
    echo "   "
    echo "              Settings -> Device information -> More Information"
    echo "              -> Developer and enable 'Remote debugging'"
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

function verify_update() {
    echo ""
    echo "Was your device updated?"
    PS3='?: '
    options=("Yes" "No")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                echo "Nice"
                ;;
            "No")
                echo "Please, contact us. We will look what we can do for you."
                sleep 2
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function go_update() {
    echo "Rebooting in fastboot mode"
    ./adb.mac reboot bootloader
    echo "Flashing boot"
    ./fastboot.mac flash update/boot boot.img
    echo "Do you want to keep your user data ? (Some users has problems in first reboot, if you have, please reflash and select not to keep the data)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) ./fastboot.mac flash userdata update/userdata.img; break;;
        esac
    done
    echo "Flashing system"
    ./fastboot.mac flash update/system system.img
    echo "Removing cache"
    ./fastboot.mac erase cache
    echo "Rebooting"
    ./fastboot.mac reboot
    ./adb.mac wait-for-device
    echo "Updated!"
    sleep 2
    verify_update
}

function update_accepted() {
    echo "${green} "
    echo "       ............................................................."
    echo "${cyan} "
    echo "              Is your device rooted?"
    echo " "
    echo " "
    echo "              Connect your phone to USB, then:"
    echo " "
    echo "              Settings -> Device information -> More Information"
    echo "              -> Developer and enable 'Remote debugging'"
    echo "${green} "
    echo "       ............................................................."
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
    echo "         ............................................................."
    echo "${cyan} "
    echo "                Which is your device?"
    echo " "
    echo " "
    echo "                Connect your phone to USB, then:"
    echo " "
    echo "                Settings -> Device information -> More Information"
    echo "                -> Developer and enable 'Remote debugging'"
    echo "${green} "
    echo "         ............................................................."
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
                main
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
    echo "Done!"
    sleep 1
}

function option_two() {
    echo "${green} "
    echo "       ............................................................."
    echo "${cyan} "
    echo "                          What you what to do?"
    echo "${green} "
    echo "       ............................................................."
    echo "${normal} "
    PS3='#?: '
    options=("Root" "Update" "Change update channel" "Android rules" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "Root")
                root
                main
                ;;
            "Update")
                update
                main
                ;;
            "Change update channel")
                update_channel
                main
                ;;
            "Android rules")
                rules
                main
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
    update_channel
    main
}

function about {
    echo "Credits and about info here"
    pause "Press ${red}[Enter]${normal} to return main menu..."
    main
}

function main() {
    echo ""
    echo "${green}       ............................................................."
    echo " "
    echo " "
    echo " "
    echo "    ${cyan}                   ${cyan}FirefoxOS Builds installer       "
    echo " "
    echo " "
    echo " "
    echo "${green}       ............................................................."
    echo ""
    echo ""
    echo " ${normal} Welcome to the FirefoxOS Builds installer. Please enter the number of"
    echo "  your selection & follow the prompts."
    echo ""
    echo ""
    echo "      1)  Update your device"
    echo "      2)  Advanced"
    echo "      3)  Exit"
    echo ""
    echo "      0)  About"
    echo ""
    read mainmen
    if [ "$mainmen" == 1 ] ; then
        option_one
    elif [ "$mainmen" == 2 ] ; then
        option_two
    elif [ "$mainmen" == 0 ] ; then
        about
    elif [ "$mainmen" == 3 ] ; then
        echo ""
        echo "                    ------------------------------------------"
        echo "                        Exiting FirefoxOS Builds installer   "
        sleep 2
        exit 0
    elif [ "$mainmen" != 1 ] && [ "$mainmen" != 2 ] && [ "$mainmen" != 0 ]; then
        echo ""
        echo ""
        echo "                        Enter a valid number   "
        echo ""
        sleep 2
        main
    fi
}

main