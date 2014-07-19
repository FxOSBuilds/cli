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
    ./adb.mac wait-for-device
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

function downgrade_inari_root_success() {
    echo ""
    echo "Was your ZTE Open downgraded successful to FirefoxOS 1.0?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_inari_ready; break;;
            No ) echo "Please contact us with the logs"; main;;
        esac
    done
}

function downgrade_inari() {
    echo ""
    echo "We are going to push some files to the sdcard"
    ./adb.mac shell mkdir /sdcard/fxosbuilds
    ./adb.mac shell "rm /sdcard/fxosbuilds/inari-update.zip"
    ./adb.mac shell "rm /sdcard/fxosbuilds/inari-update-signed.zip"
    ./adb.mac push root/inari-update.zip /sdcard/fxosbuilds/inari-update.zip
    ./adb.mac push root/inari-update-signed.zip /sdcard/fxosbuilds/inari-update-signed.zip
    echo ""
    echo "Rebooting on recovery mode"
    ./adb.mac reboot recovery
    sleep 3
    echo "${green}"
    echo "Now you need to install first the ${cyan}inari-update.zip${green} package"
    echo "${normal}"
    pause "Press ${red}[Enter]${normal} when you finished it to continue..."
    ./adb.mac wait-for-device
    echo ""
    echo "Now your device will be on a bootloop. Don't worry is the"
    echo "normal process. Now we will try to boot into recovery again."
    ./adb.mac reboot recovery
    echo "${green}"
    echo "Now you need to install first the ${cyan}inari-update-signed.zip${green} package"
    echo "${normal}"
    pause "Press ${red}[Enter]${normal} when you finished it to continue..."
    ./adb.mac wait-for-device
    echo ""
    echo "Now finish the new setup of FirefoxOS."
    echo ""
    pause "Press ${red}[Enter]${normal} when you finished it to continue..."
    echo "Rebooting device"
    ./adb.mac reboot
    echo ""
    ./adb.mac wait-for-device
    downgrade_inari_root_success
}

function recovery_inari() {
    echo ""
    echo "Preparing"
    ./adb.mac shell mkdir /sdcard/fxosbuilds
    ./adb.mac shell "rm /sdcard/fxosbuilds/cwm.img"
    ./adb.mac shell "rm /sdcard/fxosbuilds/stock-recovery.img"
    echo "Creating a backup of your recovery"
    ./adb.mac shell echo 'busybox dd if=/dev/mtd/mtd0 of=/sdcard/fxosbuilds/stock-recovery.img bs=4k' \| su
    ./adb.mac pull /sdcard/fxosbuilds/stock-recovery.img stock-recovery.img
    echo "Pushing recovery the new recovery"
    ./adb.mac push root/recovery-clockwork-6.0.3.3-roamer2.img /sdcard/fxosbuilds/cwm.img
    ./adb.mac shell echo 'flash_image recovery /sdcard/fxosbuilds/cwm.img' \| su
    echo "${green}Success!${normal}"
}

function root_inari_ready() {
    tmpf=/tmp/root-zte-open.$$
    echo "               ${green}** Read first **${normal}"
    echo ""
    echo "Not unplug your device if the device freezes or"
    echo "is stucked on boot logo. Just use the power"
    echo "button to turn off your device and turn on again"
    echo "to try again the exploit."
    echo ""
    sleep 6
    while true ; do
        ./adb.mac wait-for-device
        ./adb.mac push root/root-zte-open /data/local/tmp/
        ./adb.mac shell /data/local/tmp/root-zte-open |tee $tmpf
        cat $tmpf |grep "Got root"  >/dev/null 2>&1
        if [ $? != 0 ]; then
            echo ""
            echo "   ......................................................."
            echo ""
            echo "       ${red}Exploit failed, rebooting and trying again!${normal}"
            echo "  "
            echo "       If you get an error like this: "
            echo "  "
            echo "                 ${green}error: device not found${normal}"
            echo "  "
            echo "       Do not unplug your device. Just use the power"
            echo "       button to reboot your device. The process will"
            echo "       continue after reboot."
            echo ""
            echo "   ......................................................."
            echo ""
            ./adb.mac reboot
            rm $tmpf
        else
            echo "Enjoy!"
            ./adb.mac reboot
            ./adb.mac wait-for-device
            echo "Now we are going to flash your recovery.."
            sleep 2
            recovery_inari
            echo ""
            echo "Rebooting "
            sleep 1
            ./adb.mac reboot
            sleep 3
        fi
    done
}

function root_inari() {
    echo "   "
    echo "${red}                            ** IMPORTANT **${normal}"
    echo "   "
    echo "             Connect your phone to USB, then:"
    echo "   "
    echo "${cyan}             Settings -> Device information -> More Information"
    echo "             -> Developer and enable 'Remote debugging'${normal}"
    echo "   "
    echo "             The exploit used to get root works only on FirefoxOS v1.0"
    echo "             Your ZTE Open is running Firefox OS 1.0?"
    echo "   "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_inari_ready; break;;
            No ) downgrade_inari; break;;
        esac
    done
}

function verify_update() {
    echo ""
    echo "${green}Was your device updated?${normal}"
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
    ./adb.mac shell "rm /sdcard/fxosbuilds/update.zip"
    echo "Pushing update to sdCard"
    ./adb.mac push update/update.zip /sdcard/fxosbuilds/update.zip || exit 1
    echo "Remounting partitions"
    ./adb.mac shell echo "mount -o rw,remount /system" \| su
    echo "Configuring recovery to apply the update"
    ./adb.mac shell "echo 'boot-recovery ' > /cache/recovery/command"
    ./adb.mac shell "echo '--wipe_data' >> /cache/recovery/command"
    ./adb.mac shell "echo '--wipe_cache' >> /cache/recovery/command"
    ./adb.mac shell "echo '--update_package=/sdcard/fxosbuilds/update.zip' >> /cache/recovery/command"
    ./adb.mac shell "echo 'reboot' >> /cache/recovery/command"
    echo "Reeboting into recovery"
    ./adb.mac shell "reboot recovery"
    ./adb.mac wait-for-device
    echo "Updated!"
    sleep 2
    verify_update
    main
}

function update_accepted() {
    echo "${green}   "
    echo "       ............................................................."
    echo "${cyan}   "
    echo "             Is your device rooted?"
    echo "   "
    echo "   "
    echo "             Connect your phone to USB, then:"
    echo "   "
    echo "             Settings -> Device information -> More Information"
    echo "             -> Developer and enable 'Remote debugging'"
    echo "${green}  "
    echo "       ............................................................."
    echo "${normal}   "
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
    echo "${green}   "
    echo "       ............................................................."
    echo "${cyan}   "
    echo "   "
    echo "             Connect your phone to USB, then:"
    echo "   "
    echo "             Settings -> Device information -> More Information"
    echo "             -> Developer and enable 'Remote debugging'"
    echo "${green}  "
    echo "       ............................................................."
    echo "${normal}   "
    PS3='Are you ready?: '
    options=("Yes" "No")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                root_inari
                ;;
            "No")
                echo "Back when you are ready"
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
    echo "${green}   "
    echo "       ............................................................."
    echo "${cyan}   "
    echo "                           What you want to do?"
    echo "${green}  "
    echo "       ............................................................."
    echo "${normal}   "
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