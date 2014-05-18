#!/bin/bash
echo "Connect your phone to USB, then:"
echo "Settings -> Device information -> More Information -> Developer"
echo "and enable 'Remote debugging'"
echo

tmpf=/tmp/root-zte-open.$$
while true ; do

	adb wait-for-device
	adb push root-zte-open /data/local/tmp/
	adb shell /data/local/tmp/root-zte-open |tee $tmpf
	cat $tmpf |grep "Got root"  >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "Exploit failed, rebooting and trying again!"
		echo
		adb reboot
		rm $tmpf
	else
		echo "Enjoy!"
		exit
	fi
done
