#!/bin/bash

function root_inari() {
    echo "    ........................."
    echo "   "
    echo "      Which is your device?"
    echo "   "
    echo "    ........................."
    echo "   "
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
    ./adb.mac reboot bootloader
    ./fastboot.mac flash boot update/boot.img
    echo "Do you want to keep your user data ? (Some users has problems in first reboot, if you have, please reflash and select not to keep the data)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) ./fastboot.mac flash userdata update/userdata.img; break;;
        esac
    done
    ./fastboot.mac flash system update/system.img
    ./fastboot.mac flash recovery update/recovery.img
    ./fastboot.mac erase cache
    ./fastboot.mac reboot
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

# I know, i love functions :P
main