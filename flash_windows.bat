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
adb.exe wait-for-device
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
GOTO main
)
IF /I '%INPUT%'=='2' (
echo Aborted 
GOTO main
)
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
goto:eof

:downgrade_hamachi_root_success
echo. text
goto:eof

:adb_hamachi_root
echo. text
goto:eof

:downgrade_hamachi
echo. text
goto:eof

:adb_root_select
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
echo          1) Yes
echo          2) No
echo          3) Back menu
echo.
echo.

SET INPUT=
SET /P INPUT=Are you ready to start adb root process?:

IF /I '%INPUT%'=='1' GOTO adb_hamachi_root
IF /I '%INPUT%'=='2' echo Carefull! you need to have root access to update
IF /I '%INPUT%'=='3' GOTO main
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
IF /I '%INPUT%'!='3' GOTO bad_number
goto:eof

:recovery_hamachi
echo. text
goto:eof

:root_hamachi_ready
echo. text
goto:eof

:root_hamachi
echo. text
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

IF /I '%INPUT%'=='1' (
echo Nice
GOTO main
)
IF /I '%INPUT%'=='2' (
echo Please, contact us. We will look what we can do for you.
sleep 2
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
adb.exe remount
echo Configuring recovery to apply the update
adb.exe shell "echo 'boot-recovery ' > /cache/recovery/command"
adb.exe shell "echo '--wipe_data' >> /cache/recovery/command"
adb.exe shell "echo '--wipe_cache' >> /cache/recovery/command"
adb.exe shell "echo '--update_package=/sdcard/fxosbuilds/update.zip' >> /cache/recovery/command"
adb.exe shell "echo 'reboot' >> /cache/recovery/command"
echo Reeboting into recovery
adb.exe shell "reboot recovery"
adb.exe wait-for-device
echo Updated!
sleep 2
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
IF /I '%INPUT%'=='3' exit
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
IF /I '%INPUT%'=='3' exit
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
echo       2) ADB root
echo       3) Update
echo       4) Change update channel
echo       5) Back menu
echo.
echo.

SET INPUT=
SET /P INPUT=#?:

IF /I '%INPUT%'=='1' GOTO root
IF /I '%INPUT%'=='2' GOTO adb_root_select
IF /I '%INPUT%'=='3' GOTO update
IF /I '%INPUT%'=='4' GOTO update_channel
IF /I '%INPUT%'=='5' GOTO main
IF /I '%INPUT%'!='1' GOTO bad_number
IF /I '%INPUT%'!='2' GOTO bad_number
IF /I '%INPUT%'!='3' GOTO bad_number
IF /I '%INPUT%'!='4' GOTO bad_number
IF /I '%INPUT%'!='5' GOTO bad_number
goto:eof

:option_one
call:rules
call:root
call:update
goto:eof

:about
echo Credits and about info here
pause Press ${red}[Enter]${normal} to return main menu...
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
