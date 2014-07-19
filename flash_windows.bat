@echo off

title Firefox OS Builds installer

call:main

:channel_ota
echo Remounting...
adb.exe remount
echo Removing old channel
adb.exe shell "rm /system/b2g/defaults/pref/updates.js"
echo Pushing new OTA channel
adb.exe push ${files_dir}/updates.js $B2G_PREF_DIR/updates.js
echo Rebooting-...
adb.exe reboot
goto:eof

:update_channel
echo.
echo We are going to change the update channel,
echo so, in the future you will receive updates
echo without flash every time.
sleep 2
echo.
echo   1) Yes
echo   2) No
echo.
echo Are you ready?: 
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

:verify_root
echo.
echo Was your device rooted?
echo.
echo    1) Yes
echo    2) No
echo.

SET INPUT=
SET /P INPUT=?: 

IF /I '%INPUT%'=='1' echo Nice
IF /I '%INPUT%'=='2' (
echo Please, contact us. We will look what we can do for you
sleep 2
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:root_hamachi_ready
echo.
echo Rebooting the device
adb.exe reboot bootloader
echo Flashing the new recovery
fastboot.exe flash recovery root/hamachi_clockworkmod_recovery.img
echo.
echo Now power off your device, and retire the battery for 5 seconds, be sure
echo of your device is pluged to your computer.
echo.
echo Press [Enter] key to continue...
PAUSE >nul
echo.
echo Waiting for device
adb.exe wait-for-device
echo Push the SU binary package for root access
adb.exe shell "rm /sdcard/fxosbuilds/update-alcatel-su.zip"
adb.exe shell mkdir /sdcard/fxosbuilds
adb.exe push root/root_alcatel-signed.zip /sdcard/fxosbuilds/update-alcatel-su.zip
echo Rebooting on recovery mode
adb.exe reboot recovery
echo Now you need to install first the update-alcatel-su.zip package
echo.
echo Press [Enter] when you finished it to continue...
PAUSE >nul
echo.
echo Waiting for device
adb.exe wait-for-device
echo Rooted
sleep 1
echo.
echo Rebooting device
adb.exe reboot
adb.exe wait-for-device
call:verify_root
goto:eof

:root_hamachi
echo.
echo                               ** IMPORTANT **
echo.
echo              Connect your phone to USB, then:
echo. 
echo              Settings -> Device information -> More Information
echo              -> Developer and enable 'Remote debugging'
echo. 
echo   1) Yes
echo   2) No
echo.

SET INPUT=
SET /P INPUT=Are you sure you want to continue?: 

IF /I '%INPUT%'=='1' GOTO root_hamachi_ready
IF /I '%INPUT%'=='2' (
echo You are not sure, come back when you will :)
goto main
)
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
echo Please, contact us. We will look what we can do for you.
sleep 2
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:go_update
echo Rebooting in fastboot mode
adb.exe. reboot bootloader
echo Flashing boot
fastboot.exe flash update/boot boot.img
echo Do you want to keep your user data ? (Some users has problems in first reboot, if you have, please reflash and select not to keep the data)
echo   1) Yes
echo   2) No
echo.
SET INPUT=
SET /P INPUT=#?:
IF /I '%INPUT%'=='1' echo data not erased
IF /I '%INPUT%'=='2' fastboot.exe flash userdata update/userdata.img
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
echo Flashing system
fastboot.exe flash update/system system.img
echo Removing cache
fastboot.exe erase cache
echo Rebooting
fastboot.exe reboot
adb.exe wait-for-device
echo Updated!
sleep 2
goto verify_update
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
sleep 5
GOTO go_update
)
IF /I '%INPUT%'=='2' (
echo You need to be root first to update
sleep 2
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
echo
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
echo        Are you ready?: 
echo.

SET INPUT=
SET /P INPUT=Are you ready?:

IF /I '%INPUT%'=='1' GOTO root_hamachi
IF /I '%INPUT%'=='2' (
echo Back when you are ready
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:not_agree
echo ** You don't agree **
sleep 3
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
sleep 2
goto:eof

:bad_number_main
echo. 
echo Enter a valid number
sleep 2
GOTO main
goto:eof

:quit
echo.
echo       ------------------------------------------
echo           Exiting FirefoxOS Builds installer 
sleep 2
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
