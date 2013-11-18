#/bin/bash

adb forward tcp:9222 tcp:9222
adb shell svc power stayon usb

