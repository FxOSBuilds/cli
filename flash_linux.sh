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

function downgrade_inari_root_success() {
    echo "Was your ZTE Open downgraded successful to FirefoxOS 1.0?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_inari_ready; break;;
            No ) echo "Please contact us with the logs"; break;;
        esac
    done
}

function adb_root() {
    echo ""
    echo "Creating a copy of boot.img"
    ./adb shell echo 'cat /dev/mtd/mtd1 > /sdcard/fxosbuilds/boot.img' \| su
    echo "building the workspace"
    mkdir boot-init
    cp mkbootfs boot-init
    cp mkbootimg boot-init
    cp default.prop boot-init
    cd boot-init
    ./adb pull /sdcard/fxosbuilds/boot.img
    abootimg -x boot.img
    mkdir initrd
    cd initrd 
    mv ../initrd.img initrd.gz
    echo "boot change process"
    gunzip initrd.gz
    cpio -id < initrd
    rm default.prop
    echo "new default.prop"
    cd ..
    mv mkbootfs initrd/
    mv default.prop initrd/
    cd initrd
    ./mkbootfs . | gzip > ../newinitramfs.cpio.gz
    cd ..
    ./mkbootimg --kernel zImage --ramdisk newinitramfs.cpio.gz --base 0x200000 --cmdline 'androidboot.hardware=roamer2' -o newboot.img
    ./adb push newboot.img /sdcard/fxosbuilds/newboot.img
    ./adb shell echo 'flash_image boot /sdcard/fxosbuilds/newboot.img' \| su
    echo "Success!"
    sleep 3
    main
}

function downgrade_inari() {
    echo "Pushing files to sdcard for downgrade"
    ./adb push root/update-base-inari.zip /sdcard/fxosbuilds/update-base-inari.zip
    echo "          **Files pushed correct to device**"
    sleep 3
    echo "   "
    echo "   ..................................................."
    echo "   "
    echo "                    Steps to downgrade"
    echo "   "
    echo "   We pushed a files to your sdcard:"
    echo "   "
    echo "   1. update-base-inari.zip"
    echo "   "
    echo "   We are going to"
    echo "   Your phone will reboot in recovery mode, so follow"
    echo "   those steps:"
    echo "   "
    echo "   a. Use Vol- to go down to the option -> wipe cache/"
    echo "   factory reset"
    echo "   b. Select the option with Power button"
    echo "   c. Use Vol- to go down to the option -> Yes "
    echo "   d. Select the option with Power button to start"
    echo "   deleting the content of cache partition."
    echo "   e. Use Vol- to go down to the option -> apply update"
    echo "   from external storage"
    echo "   f. Use Vol- to go down to the folder-> fxosbuilds"
    echo "   g. Select the option with Power button to enter in"
    echo "   folder."
    echo "   h. Use Vol- to go down and select the package -> "
    echo "   update-base-inari.zip"
    echo "   i. Use Vol- to go down to the option -> Yes"
    echo "   j. Select the option with Power button to start the"
    echo "   downgrade."
    echo "   k. Select the option -> reboot the system now"
    echo "   "
    echo "   ..................................................."
    echo "   "
    read -s -n 1 -p "   Press [Enter] key to reboot on recovery mode..."
    ./adb reboot recovery
    ./adb wait-for-device
    downgrade_inari_root_success
}

function recovery_inari() {
    ./adb shell mkdir /sdcard/fxosbuilds
    ./adb shell "rm /sdcard/fxosbuilds/cwm.img"
    ./adb shell "rm /sdcard/fxosbuilds/stock-recovery.img"
    echo "Creating a backup"
    ./adb shell echo 'busybox dd if=/dev/mtd/mtd0 of=/sdcard/fxosbuilds/stock-recovery.img bs=4k' \| su
    ./adb pull /sdcard/fxosbuilds/stock-recovery.img stock-recovery.img
    echo "Pushing recovery"
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
            echo "If you get a something like this: "
            echo "  "
            echo "           error: device not found"
            echo "  "
            echo "Do not unplug your device. Just use the power"
            echo "button to reboot your device."
            echo ""
            echo "..............................................."
            echo ""
            ./adb reboot
            rm $tmpf
        else
            echo "Enjoy!"
            ./adb reboot
            ./adb wait-for-device
            recovery_inari
            adb_root
            ./adb reboot
            echo "Rebooting..."
            sleep 3
            main
        fi
    done
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
    echo "** Sorry, we are working on a root for this device. **"
    sleep 5
    echo "             **Returning to main menu**"
    sleep 1
    main
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

function update_inari_ready() {
    ./adb shell "rm /sdcard/fxosbuilds/update.zip"
    echo "Pushing update to sdCard"
    ./adb push update/update.zip /sdcard/fxosbuilds/update.zip || exit 1
    echo "Remounting partitions"
    ./adb remount
    echo "Configuring recovery to apply the update"
    ./adb shell "echo 'boot-recovery ' > /cache/recovery/command"
    ./adb shell "echo '--update_package=/sdcard/fxosbuilds/update.zip' >> /cache/recovery/command"
    ./adb shell "echo '--wipe_cache' >> /cache/recovery/command"
    echo "Do you want to erase data partition?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) ./adb shell "echo '--wipe_data' >> /cache/recovery/command"; break;;
            No ) break;;
        esac
    done
    ./adb shell "echo 'reboot' >> /cache/recovery/command"
    ./adb shell "reboot recovery"
    echo "Updated!"
}

function delete_extra_gecko_files_on_device() {
    files_to_remove="$(cat <(ls $B2G_OBJDIR) <(run_adb shell "ls /system/b2g" | tr -d '\r') | sort | uniq -u)"
    if [ "$files_to_remove" != "" ]; then
        ./${files_dir}adb shell "cd /system/b2g && rm $files_to_remove" > /dev/null
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
    ./${files_dir}adb wait-for-device
    ./${files_dir}adb shell stop b2g &&
    ./${files_dir}adb remount &&
    delete_extra_gecko_files_on_device &&
    ./${files_dir}adb push $B2G_OBJDIR /system/b2g &&
    echo " "
    echo "Restarting B2G ...." &&
    echo " "
    ./${files_dir}adb shell start b2g

    # Working on gaia
    echo "Flashing Gaia"
    echo " "
    ./${files_dir}adb shell stop b2g
    for FILE in `run_adb shell ls /data/local | tr -d '\r'`;
    do
        if [ $FILE != 'tmp' ]; then
            ./${files_dir}adb shell rm -r /data/local/$FILE
        fi
    done
    ./${files_dir}adb shell rm -r /cache/*
    ./${files_dir}adb shell rm -r /data/b2g/*
    ./${files_dir}adb shell rm -r /data/local/webapps
    ./${files_dir}adb remount
    ./${files_dir}adb shell rm -r /system/b2g/webapps

    echo " "
    echo "Installing Gaia"
    ./${files_dir}adb start-server
    ./${files_dir}adb shell stop b2g 
    ./${files_dir}adb shell rm -r /cache/*
    echo ""
    echo "Remounting partition to start the gaia install"
    ./${files_dir}adb remount
    cd update/gaia
    python ../install-gaia.py "adb" ${GAIA_INSTALL_PARENT}
    cd ..
    echo ""
    echo "Gaia installed"
    echo ""
    echo "Starting system"
    ./${files_dir}adb shell start b2g
    echo ""
    echo "..."
    # install default data
    ./${files_dir}adb shell stop b2g
    echo "......"
    run_adb remount
    echo "........."
    ./${files_dir}adb push gaia/profile/settings.json /system/b2g/defaults/settings.json
    #ifdef CONTACTS_PATH
    #    ./${files_dir}adb push profile/contacts.json /system/b2g/defaults/contacts.json
    #else
    echo "............"
    ./${files_dir}adb shell rm /system/b2g/defaults/contacts.json
    #endif
    echo "${green}DONE!"
    ./${files_dir}adb shell start b2g
    echo " "
    echo "Let's back"
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
    echo " ${normal} Welcome to the FirefoxOS Builds installer. Please enter "
    echo "  the number of your selection & follow the prompts."
    echo ""
    echo ""
    echo "      1)  Root your device"
    echo "      2)  Update your device"
    echo "      3)  Clean fxosbuilds sdcard folder"
    echo "      4)  Download the latest update"
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
        echo "Not implemented"
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