#!/bin/bash

GREEN='\033[0;32m' # Green Color
NC='\033[0m' # No Color



if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    read _ DEBIAN_VERSION_NAME <<< "$VERSION"
    echo "Running Debian $DEBIAN_VERSION_NAME" | sed 's/[()]//g'
    DIST=$DEBIAN_VERSION_NAME
    # Remove parentheses from the variable value
    DIST="${DIST//\(/}"
    DIST="${DIST//\)/}"
    DEB="deb http://deb.debian.org/debian $DIST contrib non-free"
    if grep -Fxq "$DEB" /etc/apt/sources.list
    then
        echo "The sources are updated."
    else
    	echo "Inserting sources..."
        echo $DEB >> /etc/apt/sources.list
    fi
    sudo apt-get update
    sudo apt-get install linux-image-$(uname -r|sed 's,[^-]*-[^-]*-,,') linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') broadcom-sta-dkms
    sudo apt-get install -f
    sudo dpkg-reconfigure broadcom-sta-dkms
    if find /lib/modules/$(uname -r)/updates | grep -q "wl.ko"; then
        printf "${RED}The module wl.ko was found.\n"
    fi
    sudo modprobe -r b44 b43 b43legacy ssb brcmsmac bcma
    sudo modprobe wl
    echo "
    
#!/bin/sh

WIFI=$(find /sys/class/net -follow -maxdepth 2 -name wireless 2>/dev/null|cut -d / -f 5|head -1)
echo ip link set $WIFI down
ip link set $WIFI down >/dev/null 2>&1
modprobe -r wl brcmsmac
modprobe -r cfg80211 brcmsmac cordic brcmutil bcma

if [ "$1" = "wl" ]; then
        modprobe wl
else
        modprobe brcmsmac
fi

sleep 0.1
WIFI=$(find /sys/class/net -follow -maxdepth 2 -name wireless 2>/dev/null|cut -d / -f 5|head -1)
echo ip link set $WIFI up
ip link set $WIFI up >/dev/null 2>&1

    " >> wifi.sh
    chmod + x ./wifi.sh
else
    echo "Not running a distribution with /etc/os-release available"
    exit
fi





