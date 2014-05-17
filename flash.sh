#!/bin/bash
./adb reboot bootloader
./fastboot flash boot boot.img
echo "Do you want to keep your user data ? (Some users has problems in first reboot, if you have, please reflash and select not to keep the data)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) ./fastboot flash userdata userdata.img; break;;
    esac
done
./fastboot flash system system.img
./fastboot flash recovery recovery.img
./fastboot erase cache
./fastboot reboot
