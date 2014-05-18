@ECHO OFF
%cd:~0,2%
SET workDIR=%~dp0


ECHO ***** WARNING *****
ECHO WILL WIPE YOUR DATA
ECHO ***** WARNING *****
SET /P _choice=Do you want to flash userdata [Y/N]? 

adb.exe reboot bootloader
goto system

:: Flash system
:system
IF EXIST "%workDIR%system.img" (
	fastboot.exe flash system system.img
	IF /I "%_choice%"=="Y" goto userdata
	goto boot
) ELSE (
	ECHO %workDIR%system.img not found to flash
	goto error
)

:: Flash userdata
:userdata
IF EXIST "%workDIR%userdata.img" (
	fastboot.exe flash userdata userdata.img
	goto boot
) ELSE (
 	ECHO %workDIR%userdata.img not found to flash
	goto error
)

:: Flash boot aka kernel
:boot
IF EXIST "%workDIR%boot.img" (
	fastboot.exe flash boot boot.img
	goto recovery
) ELSE (
	ECHO %workDIR%boot.img not found to flash
	goto error
)

:: Flash Recovery
:recovery
IF EXIST "%workDIR%recovery.img" (
	fastboot.exe flash recovery recovery.img
	goto end
) ELSE (
	ECHO %workDIR%recovery.img not found to flash
	goto error
)

:error
ECHO Something is wrong. Make sure you follow all the steps... Press any key to exit...
PAUSE >nul
EXIT

:end
ECHO Everything completed. Press any key to exit/reboot...
PAUSE >nul
fastboot reboot
EXIT
