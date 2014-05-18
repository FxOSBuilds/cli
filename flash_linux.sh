#!/bin/bash

function root_inari() {
    echo "    ........................."
    echo "   "
    echo "      Which is your device?"
    echo "   "
    echo "    ........................."
    echo "   "
    echo "Connect your phone to USB, then:"
    echo "Settings -> Device information -> More Information -> Developer"
    echo "and enable 'Remote debugging'"
    echo

    tmpf=/tmp/root-zte-open.$$
    while true ; do

        adb wait-for-device
        adb push root/root-zte-open /data/local/tmp/
        adb shell /data/local/tmp/root-zte-open |tee $tmpf
        cat $tmpf |grep "Got root"  >/dev/null 2>&1
        if [ $? != 0 ]; then
            echo "Exploit failed, rebooting and trying again!"
            echo "  "
            echo "Not unplug your device if the device frezes or is stucked on boot logo."
            echo "Just use the power button to turn off your device and turn on again to"
            echo "try again the exploit."
            echo
            adb reboot
            rm $tmpf
        else
            echo "Enjoy!"
            exit
        fi
    done
}

function root_hamachi() {
    echo test
}

function root_leo() {
    echo "We are working on a root for this device. Thanks"
}

function root_helix() {
    echo "We are working on a root for this device. Thanks"
}

function root() {
    echo "    ........................."
    echo "   "
    echo "      Which is your device?"
    echo "   "
    echo "    ........................."
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

function update_accepted() {
    ./adb reboot bootloader
    ./fastboot flash boot update/boot.img
    echo "Do you want to keep your user data ? (Some users has problems in first reboot, if you have, please reflash and select not to keep the data)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) ./fastboot flash userdata update/userdata.img; break;;
        esac
    done
    ./fastboot flash system update/system.img
    ./fastboot flash recovery update/recovery.img
    ./fastboot erase cache
    ./fastboot reboot
    echo "Done!"
}

function update() {
    echo " "
    echo "    **********************************"
    echo "    *                                *"
    echo "    *    Disclaimer explanation      *"
    echo "    *         bla bla bla            *"
    echo "    *                                *"
    echo "    **********************************"
    echo " "
    PS3='Do you agree?: '
    options=("Yes" "No" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Yes")
                update_accepted
                ;;
            "No")
                echo "You reject it!";
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
    echo "    **********************************"
    echo "    *                                *"
    echo "    *    Community update system     *"
    echo "    *                                *"
    echo "    *      firefoxosbuilds.org       *"
    echo "    *                                *"
    echo "    **********************************"
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