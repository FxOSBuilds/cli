#!/bin/bash
function root_inari() {
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
            main
        fi
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

function update_accepted() {
    #
    main
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