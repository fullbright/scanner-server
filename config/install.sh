#!/bin/bash

apt-get update && apt-get install -y git libconfuse-dev libsane-dev libudev-dev libusb-dev curl build-essential checkinstall pkg-config libdbus-1-dev libdbus-glib-1-dev
apt-get install -y libusb-dev build-essential libsane-dev libavahi-client-dev libavahi-glib-dev vim
apt-get install hplib

cd "/usr/local/src"
git clone https://github.com/mdengler/scanbd.git
cd "/usr/local/src/scanbd"

./configure
make all
make install

cp /usr/local/src/scanbd/scanbd_dbus.conf  /etc/dbus-1/system.d/

cd "/usr/local/src"
git clone git://git.debian.org/sane/sane-backends.git
cd "/usr/local/src/sane-backends"

find /usr/lib -name 'libsane-dll.so'

./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu/ --sysconfdir=/etc --localstatedir=/var  --enable-avahi
make
make install

sane-find-scanner
scanimage -L

#/bin/bash
