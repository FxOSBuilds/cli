#!/bin/bash

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

function root_leo_ready() {
    echo ""
    echo "Detecting the device"
    ./adb wait-for-device
    echo "adb shell work in process"
    ./adb shell "rm /data/gpscfg/gps_env.conf 2>/dev/null"
    ./adb shell "ln -s /data /data/gpscfg/gps_env.conf"
    echo "Rebooting the device ...."
    ./adb reboot
    ./adb wait-for-device
    echo "¿Exploit?"
    ./adb shell "echo 'ro.kernel.qemu=1' > /data/local.prop"
    ./adb reboot
    ./adb wait-for-device}
    echo "Remounting"
    ./adb remount
    echo "Pushing SU"
    ./adb push root/su /system/bin/su
    ./adb shell "chmod 6755 /system/bin/su"
    ./adb shell "ln -s /system/bin/su /system/xbin/su"
    echo "Cleaning up"
    ./adb shell "rm /data/local.prop"
    ./adb shell "rm /data/gpscfg/*"
    ./adb shell "chmod 771 /data/"
    echo "Rebooting"
    ./adb reboot
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
    echo "   "
    echo "               ** IMPORTANT **"
    echo "   "
    echo "   Connect your phone to USB, then:"
    echo "   "
    echo "   Settings -> Device information -> More Information"
    echo "   -> Developer and enable 'Remote debugging'"
    echo "   "
    echo "This is a non-test exploit and not sure about it works"
    echo "are you sure to continue?"
    echo "   "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) root_leo_ready; break;;
            No ) main; break;;
        esac
    done
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

function update_inari() {
    echo "You need to device rooted to install the"
    echo "update. Is your ZTE Open rooted?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) update_inari_ready; break;;
            No ) echo "** You need to root your device first **"; main; break;;
        esac
    done
}

function update_hamachi() {
    echo "** Sorry, we are working on an update process for this device. **"
    sleep 5
    echo "             **Returning to main menu**"
    sleep 1
    main
}

function update_leo() {
    echo "** Sorry, we are working on an update process for this device. **"
    sleep 5
    echo "             **Returning to main menu**"
    sleep 1
    main
}

function update_helix() {
    echo "** Sorry, we are working on an update process for this device. **"
    sleep 5
    echo "             **Returning to main menu**"
    sleep 1
    main
}

function update_accepted() {
    echo "   "
    echo "   ..................................................."
    echo "   "
    echo "                  Which is your device?"
    echo "   "
    echo "   "
    echo "   Connect your phone to USB, then:"
    echo "   "
    echo "   Settings -> Device information -> More Information"
    echo "   -> Developer and enable 'Remote debugging'"
    echo "   ..................................................."
    echo "   "
    PS3='#: '
    options=("ZTE Open" "Alcatel One Touch Fire" "LG Fireweb" "Huawei Y300" "Back menu")
    select opt in "${options[@]}"
    do
        case $opt in
            "ZTE Open")
                update_inari
                ;;
            "Alcatel One Touch Fire")
                update_hamachi
                ;;
            "LG Fireweb")
                update_leo
                ;;
            "Huawei Y300")
                update_helix
                ;;
            "Back menu")
                main
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

function root_accepted() {
    echo "   "
    echo "   ..................................................."
    echo "   "
    echo "                  Which is your device?"
    echo "   "
    echo "   "
    echo "   Connect your phone to USB, then:"
    echo "   "
    echo "   Settings -> Device information -> More Information"
    echo "   -> Developer and enable 'Remote debugging'"
    echo "   ..................................................."
    echo "   "
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
    echo "   ..................................................."
    echo "   "
    echo "                      Disclaimer"
    echo "   "
    echo "   By downloading and using this root way you accept"
    echo "   that your warranty is void and we are not in no way"
    echo "   responsible for any damage or data loss may incur."
    echo "   "
    echo "   We are not responsible for bricked devices, dead SD"
    echo "   cards, or you getting fired because the alarm app" 
    echo "   failed. Please do some research if you have any"
    echo "   concerns about this update before flashing it."
    echo "   "
    echo "   ..................................................."
    echo "   "
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
    echo "   ..................................................."
    echo "   "
    echo "                      Disclaimer"
    echo "   "
    echo "   By downloading and installing the update you accept"
    echo "   that your warranty is void and we are not in no way"
    echo "   responsible for any damage or data loss may incur."
    echo "   "
    echo "   We are not responsible for bricked devices, dead SD"
    echo "   cards, or you getting fired because the alarm app" 
    echo "   failed. Please do some research if you have any"
    echo "   concerns about this update before flashing it."
    echo "   "
    echo "   ..................................................."
    echo "   "
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
    echo " "
    echo "          **********************************"
    echo "          *                                *"
    echo "          *    Community update system     *"
    echo "          *                                *"
    echo "          *      firefoxosbuilds.org       *"
    echo "          *                                *"
    echo "          **********************************"
    echo " "
    PS3='#?: '
    options=("Root your device" "Update your device" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Root your device")
    			root
    			;;
            "Update your device")
                update
                ;;
            "Quit")
    			exit 0
                break
                ;;
            *) echo "** Invalid option **";;
        esac
    done
}

main