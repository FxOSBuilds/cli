@echo off

title Firefox OS Builds installer

call:main

:channel_ota
echo Remounting...
adb.exe remount
echo Removing old channel
adb.exe shell "rm /system/b2g/defaults/pref/updates.js"
echo Pushing new OTA channel
adb.exe push files/updates.js $B2G_PREF_DIR/updates.js
echo Rebooting-...
adb.exe reboot
goto:eof

:update_channel
echo.
echo We are going to change the update channel,
echo so, in the future you will receive updates
echo without flash every time.
timeout /t 2 /nobreak
echo.
echo   1) Yes
echo   2) No
echo.

SET INPUT=
SET /P INPUT=Are you ready?:

IF /I '%INPUT%'=='1' (
GOTO channel_ota 
)
IF /I '%INPUT%'=='2' (
echo Aborted 
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:downgrade_inari_root_success
echo.
echo Was your ZTE Open downgraded successful to FirefoxOS 1.0?
echo.
echo   1) Yes
echo   2) No
echo.

SET INPUT=
SET /P INPUT=#?:

IF /I '%INPUT%'=='1' (
GOTO root_inari_ready 
)
IF /I '%INPUT%'=='2' (
echo Please contact us with the logs
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:downgrade_inari
echo.
echo We are going to push some files to the sdcard
adb.exe shell mkdir /sdcard/fxosbuilds
adb.exe shell "rm /sdcard/fxosbuilds/inari-update.zip"
adb.exe shell "rm /sdcard/fxosbuilds/inari-update-signed.zip"
adb.exe push root/inari-update.zip /sdcard/fxosbuilds/inari-update.zip
adb.exe push root/inari-update-signed.zip /sdcard/fxosbuilds/inari-update-signed.zip
echo.
echo Rebooting on recovery mode
adb.exe reboot recovery
timeout /t 3 /nobreak
echo.
echo Now you need to install first the inari-update.zip package
echo.
echo Press [Enter] when you finished it to continue...
PAUSE >nul
adb.exe wait-for-device
echo.
echo Now your device will be on a bootloop. Don't worry is the
echo normal process. Now we will try to boot into recovery again.
adb.exe reboot recovery
echo.
echo Now you need to install first the inari-update-signed.zip package
echo.
echo Press ${red}[Enter]${normal} when you finished it to continue...
PAUSE >nul
adb.exe wait-for-device
echo.
echo Now finish the new setup of FirefoxOS.
echo.
echo Press ${red}[Enter]${normal} when you finished it to continue...
PAUSE >nul
echo Rebooting device
adb.exe reboot
echo.
adb.exe wait-for-device
GOTO downgrade_inari_root_success
goto:eof

:recovery_inari
echo Preparing
adb.exe shell mkdir /sdcard/fxosbuilds
adb.exe shell "rm /sdcard/fxosbuilds/cwm.img"
adb.exe shell "rm /sdcard/fxosbuilds/stock-recovery.img"
echo Creating a backup of your recovery
adb.exe shell echo 'busybox dd if=/dev/mtd/mtd0 of=/sdcard/fxosbuilds/stock-recovery.img bs=4k' \| su
adb.exe pull /sdcard/fxosbuilds/stock-recovery.img stock-recovery.img
echo Pushing recovery the new recovery
adb.exe push root/recovery-clockwork-6.0.3.3-roamer2.img /sdcard/fxosbuilds/cwm.img
adb.exe shell echo 'flash_image recovery /sdcard/fxosbuilds/cwm.img' \| su
echo Success!
goto:eof

:root_inari_ready
echo.
echo             ** Read first **
echo 
echo Not unplug your device if the device freezes or
echo is stucked on boot logo. Just use the power
echo button to turn off your device and turn on again
echo to try again the exploit.
echo.
timeout /t 6 /nobreak
echo
echo    .......................................................
echo. 
echo        If you get an error like this: 
echo.
echo                  ${green}error: device not found${normal}
echo.
echo        Do not unplug your device. Just use the power
echo        button to reboot your device. The process will
echo        continue after reboot.
echo.
echo    .......................................................
echo.
timeout /t 6 /nobreak
adb.exe wait-for-device
adb.exe push root-zte-open /data/local/tmp/
adb.exe shell /data/local/tmp/root-zte-open
goto:eof

:root_inari
echo.
echo                               ** IMPORTANT **
echo.
echo              Connect your phone to USB, then:
echo. 
echo              Settings -> Device information -> More Information
echo              -> Developer and enable 'Remote debugging'
echo. 
echo              The exploit used to get root works only on FirefoxOS v1.0
echo              Your ZTE Open is running Firefox OS 1.0?
echo. 
echo   1) Yes
echo   2) No
echo.

SET INPUT=
SET /P INPUT=#: 

IF /I '%INPUT%'=='1' GOTO root_inari_ready
IF /I '%INPUT%'=='2' GOTO downgrade_inari
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:verify_update
echo.
echo Was your device updated?
echo.
echo    1) Yes
echo    2) No
echo.

SET INPUT=
SET /P INPUT=?: 

IF /I '%INPUT%'=='1' echo Nice
IF /I '%INPUT%'=='2' (
echo Please, contact us. We will look what we can do for you
timeout /t 2 /nobreak
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:go_update
adb.exe shell "rm /sdcard/fxosbuilds/update.zip"
echo Pushing update to sdCard
adb.exe push update/update.zip /sdcard/fxosbuilds/update.zip || exit 1
echo Remounting partitions
adb.exe shell echo "mount -o rw,remount /system" \| su
echo Configuring recovery to apply the update
adb.exe shell "echo 'boot-recovery ' > /cache/recovery/command"
adb.exe shell "echo '--wipe_data' >> /cache/recovery/command"
adb.exe shell "echo '--wipe_cache' >> /cache/recovery/command"
adb.exe shell "echo '--update_package=/sdcard/fxosbuilds/update.zip' >> /cache/recovery/command"
adb.exe shell "echo 'reboot' >> /cache/recovery/command"
echo Rebooting into recovery
adb.exe shell "reboot recovery"
adb.exe wait-for-device
echo Updated!
timeout /t 2 /nobreak
GOTO verify_update
goto:eof

:update_accepted
echo.
echo        .............................................................
echo. 
echo              Is your device rooted?
echo. 
echo. 
echo              Connect your phone to USB, then:
echo. 
echo              Settings -> Device information -> More Information
echo              -> Developer and enable 'Remote debugging'
echo. 
echo        .............................................................
echo.
echo          1) Yes
echo          2) No
echo          3) Back menu
echo.
echo.

SET INPUT=
SET /P INPUT=Are you ready?: 

IF /I '%INPUT%'=='1' (
echo The update process will start in 5 seconds
timeout /t 5 /nobreak
GOTO go_update
)
IF /I '%INPUT%'=='2' (
echo You need to be root first to update
timeout /t 2 /nobreak
GOTO root
)
IF /I '%INPUT%'=='3' GOTO main
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
IF /I '%INPUT%'!='3' GOTO bad_number
goto:eof

:root_accepted
echo.
echo        .............................................................
echo.
echo.
echo              Connect your phone to USB, then:
echo.
echo              Settings -> Device information -> More Information
echo              -> Developer and enable 'Remote debugging'
echo.
echo        .............................................................
echo.
echo             1) Yes
echo             2) No
echo.

SET INPUT=
SET /P INPUT=Are you ready?:

IF /I '%INPUT%'=='1' GOTO root_inari
IF /I '%INPUT%'=='2' (
echo Back when you are ready
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:not_agree
echo ** You don't agree **
timeout /t 3 /nobreak
GOTO main
goto:eof

:root
echo.
echo        .............................................................
echo.
echo                               Disclaimer
echo.
echo              By downloading and installing the root you accept
echo              that your warranty is void and we are not in no way
echo              responsible for any damage or data loss may incur.
echo.
echo              We are not responsible for bricked devices, dead SD
echo              cards, or you getting fired because the alarm app
echo              failed. Please do some research if you have any
echo              concerns about this update before flashing it.
echo.
echo        .............................................................
echo.
echo          1) Yes
echo          2) No
echo          3) Quit
echo.
echo.

SET INPUT=
SET /P INPUT=Do you agree?:

IF /I '%INPUT%'=='1' GOTO root_accepted
IF /I '%INPUT%'=='2' GOTO not_agree
IF /I '%INPUT%'=='3' exit 0
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
IF /I '%INPUT%'!='3' GOTO bad_number
goto:eof

:update
echo.
echo        .............................................................
echo.
echo                               Disclaimer
echo.
echo              By downloading and installing the update you accept
echo              that your warranty is void and we are not in no way
echo              responsible for any damage or data loss may incur.
echo.
echo              We are not responsible for bricked devices, dead SD
echo              cards, or you getting fired because the alarm app
echo              failed. Please do some research if you have any
echo              concerns about this update before flashing it.
echo.
echo        .............................................................
echo.
echo          1) Yes
echo          2) No
echo          3) Quit
echo.
echo.

SET INPUT=
SET /P INPUT=Do you agree?:

IF /I '%INPUT%'=='1' GOTO update_accepted
IF /I '%INPUT%'=='2' GOTO not_agree
IF /I '%INPUT%'=='3' exit 0
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
IF /I '%INPUT%'!='3' GOTO bad_number
goto:eof

:option_two
echo.
echo       .............................................................
echo.
echo                           What you want to do?
echo.
echo       .............................................................
echo.
echo       1) Root
echo       2) Update
echo       3) Change update channel
echo       4) Back menu
echo.
echo.

SET INPUT=
SET /P INPUT=#?:

IF /I '%INPUT%'=='1' (
GOTO root
main
) 
IF /I '%INPUT%'=='2' (
GOTO update
main
) 
IF /I '%INPUT%'=='3' (
GOTO update_channel
main
)
IF /I '%INPUT%'=='4' (
GOTO main
main
) 
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
IF /I '%INPUT%'!='3' GOTO bad_number
IF /I '%INPUT%'!='4' GOTO bad_number
goto:eof

:option_one
call:rules
call:root
call:update
call:update_channel
call:main
goto:eof

:about
echo Credits and about info here
echo Press ${red}[Enter]${normal} to return main menu...
PAUSE >nul
call:main
goto:eof

:bad_number
echo. 
echo Enter a valid number
timeout /t 2 /nobreak
goto:eof

:bad_number_main
echo. 
echo Enter a valid number
timeout /t 2 /nobreak
GOTO main
goto:eof

:quit
echo.
echo       ------------------------------------------
echo           Exiting FirefoxOS Builds installer 
timeout /t 2 /nobreak
exit 0
goto:eof

:main
echo.
echo       .............................................................
echo.
echo.
echo.
echo                       FirefoxOS Builds installer       
echo.
echo.
echo.
echo       .............................................................
echo.
echo.
echo   Welcome to the FirefoxOS Builds installer. Please enter the number of
echo   your selection & follow the prompts.
echo.
echo.
echo       1)  Update your device
echo       2)  Advanced
echo       3)  Exit
echo. 
echo       0)  About
echo.

SET INPUT=
SET /P INPUT= :

IF /I '%INPUT%'=='1' GOTO option_one
IF /I '%INPUT%'=='2' GOTO option_two
IF /I '%INPUT%'=='3' GOTO quit
IF /I '%INPUT%'=='0' GOTO about
IF /I '%INPUT%'!='1' GOTO bad_number_main
IF /I '%INPUT%'!='2' GOTO bad_number_main
IF /I '%INPUT%'!='3' GOTO bad_number_main
IF /I '%INPUT%'!='0' GOTO bad_number_main
goto:eof
