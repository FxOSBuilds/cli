#!/bin/bash
./adb.mac reboot bootloader
./fastboot.mac flash boot boot.img
echo "Do you want to keep your user data ? (Some users has problems in first reboot, if you have, please reflash and select not to keep the data)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) ./fastboot.mac flash userdata userdata.img; break;;
    esac
done
./fastboot.mac flash system system.img
./fastboot.mac flash recovery recovery.img
./fastboot.mac erase cache
./fastboot.mac reboot
