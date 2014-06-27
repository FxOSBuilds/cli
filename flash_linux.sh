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

function pause(){
   read -p "$*"
}

function downgrade_inari_root_success() {
    echo "Was your ZTE Open downgraded successful to FirefoxOS 1.0?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_inari_ready; break;;
            No ) echo "Please contact us with the logs"; break;;
        esac
    done
}

function adb_inari_root() {
    echo ""
    rm -r boot-init
    ./adb shell "rm /sdcard/fxosbuilds/newboot.img"
    echo "Creating a copy of boot.img"
    ./adb shell echo 'cat /dev/mtd/mtd1 > /sdcard/fxosbuilds/boot.img' \| su
    echo "building the workspace"
    mkdir boot-init
    cp ${files_dir}mkbootfs boot-init/mkbootfs
    cp ${files_dir}mkbootimg boot-init/mkbootimg
    cp ${files_dir}inari-default.prop boot-init/default.prop
    cp ${files_dir}inari-init.b2g.rc boot-init/init.b2g.rc
    cd boot-init
    echo "Copying your boot.img copy"
    ../adb pull /sdcard/fxosbuilds/boot.img
    abootimg -x boot.img
    mkdir initrd
    cd initrd 
    echo "ready?????"
    mv ../initrd.img initrd.gz
    echo "Boot change process"
    gunzip initrd.gz
    cpio -id < initrd
    rm default.prop
    rm init.b2g.rc
    sleep 30
    echo "New default.prop and init.b2g.rc"
    cd ..
    mv mkbootfs initrd/mkbootfs
    mv default.prop initrd/default.prop
    mv init.b2g.rc initrd/init.b2g.rc
    cd initrd
    ./mkbootfs . | gzip > ../newinitramfs.cpio.gz
    cd ..
    ./mkbootimg --kernel zImage --ramdisk newinitramfs.cpio.gz --base 0x200000 --cmdline 'androidboot.hardware=roamer2' -o newboot.img
    cd ..
    ./adb push boot-init/newboot.img /sdcard/fxosbuilds/newboot.img
    ./adb shell echo 'flash_image boot /sdcard/fxosbuilds/newboot.img' \| su
    echo "Success!"
    sleep 3
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
    cp ${files_dir}hamachi-default.prop boot-init/default.prop
    cd boot-init
    echo "Copying your boot.img copy"
    ./adb pull /sdcard/fxosbuilds/boot.img
    abootimg -x boot.img
    mkdir initrd
    cd initrd 
    mv ../initrd.img initrd.gz
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

function downgrade_inari() {
    echo ""
    echo "We are going to push some files to the sdcard"
    ./adb shell mkdir /sdcard/fxosbuilds
    ./adb shell "rm /sdcard/fxosbuilds/inari-update.zip"
    ./adb shell "rm /sdcard/fxosbuilds/inari-update-signed.zip"
    ./adb push root/inari-update.zip /sdcard/fxosbuilds/inari-update.zip
    ./adb push root/inari-update-signed.zip /sdcard/fxosbuilds/inari-update-signed.zip
    echo ""
    echo "Rebooting on recovery mode"
    ./adb reboot recovery
    echo ""
    echo "Now you need to install first the inari-update.zip package"
    echo ""
    pause "Press [Enter] when you finished it to continue..."
    echo ""
    ./adb wait-for-device
    echo ""
    echo "Now your device will be on a bootloop. Don't worry is the"
    echo "normal process. Now we will try to boot into recovery again."
    ./adb reboot recovery
    echo ""
    echo "Now you need to install first the inari-update-signed.zip package"
    echo ""
    pause "Press [Enter] when you finished it to continue..."
    echo ""
    echo "Now finish the new setup of FirefoxOS."
    echo ""
    pause "Press [Enter] when you finished it to continue..."
    echo "Rebooting device"
    ./adb reboot
    echo ""
    ./adb wait-for-device
    downgrade_inari_root_success
}

function adb_root_select() {
    echo "${green}   "
    echo "       ............................................................."
    echo "${cyan}   "
    echo "             Which is your device?"
    echo "   "
    echo "   "
    echo "             Connect your phone to USB, then:"
    echo "   "
    echo "             Settings -> Device information -> More Information"
    echo "             -> Developer and enable 'Remote debugging'"
    echo "${green}  "
    echo "       ............................................................."
    echo "${normal}   "
    PS3='#: '
    options=("ZTE Open" "Alcatel One Touch Fire" "LG Fireweb" "Huawei Y300" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "ZTE Open")
                adb_inari_root
                ;;
            "Alcatel One Touch Fire")
                adb_hamachi_root
                ;;
            "LG Fireweb")
                echo "We don't have an adb root method for this device"
                ;;
            "Huawei Y300")
                echo "We don't have an adb root method for this device"
                ;;
            "Back menu")
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done 
}

function recovery_inari() {
    echo "Preparing"
    ./adb shell mkdir /sdcard/fxosbuilds
    ./adb shell "rm /sdcard/fxosbuilds/cwm.img"
    ./adb shell "rm /sdcard/fxosbuilds/stock-recovery.img"
    echo "Creating a backup of your recovery"
    ./adb shell echo 'busybox dd if=/dev/mtd/mtd0 of=/sdcard/fxosbuilds/stock-recovery.img bs=4k' \| su
    ./adb pull /sdcard/fxosbuilds/stock-recovery.img stock-recovery.img
    echo "Pushing recovery the new recovery"
    ./adb push root/recovery-clockwork-6.0.3.3-roamer2.img /sdcard/fxosbuilds/cwm.img
    ./adb shell echo 'flash_image recovery /sdcard/fxosbuilds/cwm.img' \| su
    echo "Success!"
}

function root_inari_ready() {
    tmpf=/tmp/root-zte-open.$$
    echo "               ** Read first **"
    echo ""
    echo "Not unplug your device if the device freezes or"
    echo "is stucked on boot logo. Just use the power"
    echo "button to turn off your device and turn on again"
    echo "to try again the exploit."
    echo ""
    sleep 6
    while true ; do
        ./adb wait-for-device
        ./adb push root/root-zte-open /data/local/tmp/
        ./adb shell /data/local/tmp/root-zte-open |tee $tmpf
        cat $tmpf |grep "Got root"  >/dev/null 2>&1
        if [ $? != 0 ]; then
            echo ""
            echo ".............................................."
            echo ""
            echo "Exploit failed, rebooting and trying again!"
            echo "  "
            echo "If you get an error like this: "
            echo "  "
            echo "           error: device not found"
            echo "  "
            echo "Do not unplug your device. Just use the power"
            echo "button to reboot your device. The process will"
            echo "continue after reboot."
            echo ""
            echo "..............................................."
            echo ""
            ./adb reboot
            rm $tmpf
        else
            echo "Enjoy!"
            ./adb reboot
            ./adb wait-for-device
            echo "Now we are going to flash your recovery.."
            sleep 2
            recovery_inari
            echo ""
            echo"Getting adb root access"
            adb_inari_root
            echo ""
            echo "Rebooting "
            sleep 1
            ./adb reboot
            echo "Returning to main menu"
            sleep 3
            main
        fi
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

function root_inari() {
    echo "   "
    echo "               ** IMPORTANT **"
    echo "   "
    echo "   Connect your phone to USB, then:"
    echo "   "
    echo "   Settings -> Device information -> More Information"
    echo "   -> Developer and enable 'Remote debugging'"
    echo "   "
    echo "The exploit used to get root works only on FirefoxOS v1.0"
    echo "Your ZTE Open is running Firefox OS 1.0?"
    echo "   "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_inari_ready; break;;
            No ) downgrade_inari; break;;
        esac
    done
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

function root_leo() {
    echo "** Sorry, we are working on a root for this device. **"
    sleep 5
    echo "             **Returning to main menu**"
    sleep 1
    main
}

function root_helix() {
    echo "** Sorry, we are working on a root for this device. **"
    sleep 5
    echo "             **Returning to main menu**"
    sleep 1
    main
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
                "Nice"
                main
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
    verify_update
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
    PS3='#: '
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
    echo "             Which is your device?"
    echo "   "
    echo "   "
    echo "             Connect your phone to USB, then:"
    echo "   "
    echo "             Settings -> Device information -> More Information"
    echo "             -> Developer and enable 'Remote debugging'"
    echo "${green}  "
    echo "       ............................................................."
    echo "${normal}   "
    PS3='#: '
    options=("ZTE Open" "Alcatel One Touch Fire" "LG Fireweb" "Huawei Y300" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "ZTE Open")
                root_inari
                ;;
            "Alcatel One Touch Fire")
                root_hamachi
                ;;
            "LG Fireweb")
                root_leo
                ;;
            "Huawei Y300")
                root_helix
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
    echo "      1)  Root your device"
    echo "      2)  Update your device"
    echo "      3)  ADB Root"
    echo "      4)  TBD"
    echo "      5)  TBD"
    echo "      6)  TBD"
    echo "      7)  TBD"
    echo "      8)  TBD"
    echo "      9)  TBD"
    echo "      10) TBD"
    echo "      11) TBD"
    echo "      12) TBD"
    echo "      13) Exit"
    echo ""
    read mainmen 
    if [ "$mainmen" == 1 ] ; then
        root 
    elif [ "$mainmen" == 2 ] ; then
        update
    elif [ "$mainmen" == 3 ] ; then
        adb_root_select
    elif [ "$mainmen" == 4 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 5 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 6 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 7 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 8 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 9 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 10 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 11 ] ; then
        echo "Not implemented"
    elif [ "$mainmen" == 12 ] ; then 
        echo "Not implemented"
    elif [ "$mainmen" == 13 ] ; then
        echo ""
        echo "                    ------------------------------------------"
        echo "                        Exiting FirefoxOS Builds installer   "
        sleep 2
        exit 0
    elif [ "$mainmen" != 1 ] && [ "$mainmen" != 2 ] && [ "$mainmen" != 3 ] && [ "$mainmen" != 4 ] && [ "$mainmen" != 5 ] && [ "$mainmen" != 6 ] && [ "$mainmen" != 7 ] && [ "$mainmen" != 8 ] && [ "$mainmen" != 9 ] && [ "$mainmen" != 10 ] && [ "$mainmen" != 11 ] && [ "$mainmen" != 12 ]; then
        echo ""
        echo ""
        echo "                        Enter a valid number   "
        echo ""
        sleep 2
        main
    fi
}

main