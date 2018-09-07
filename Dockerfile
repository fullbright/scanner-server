from ubuntu:16.04

RUN apt-get update 
RUN apt-get install -y apt-utils net-tools \
        cmake libgcrypt11-dev libyajl-dev libboost-all-dev \
        libcurl4-openssl-dev libexpat1-dev libcppunit-dev \
        binutils-dev debhelper zlib1g-dev dpkg-dev pkg-config
RUN apt-get install -y git libconfuse-dev libsane-dev libudev-dev \
        libusb-dev curl build-essential checkinstall pkg-config \
        libdbus-1-dev libdbus-glib-1-dev
RUN apt-get install -y libusb-dev build-essential libsane-dev libavahi-client-dev libavahi-glib-dev vim
RUN apt-get install -y scanbd libsane libsane-common sane-utils

RUN apt-get update
RUN apt-get install -y hplip

# Install grive2
RUN git clone https://github.com/vitalif/grive2 && cd "grive2" && mkdir build && cd build && cmake .. && make -j4 && make install

#WORKDIR "/usr/local/src"
#RUN git clone https://github.com/mdengler/scanbd.git
#WORKDIR "/usr/local/src/scanbd"

#RUN ./configure
#RUN make all
#RUN make install

#COPY /usr/local/src/scanbd/scanbd_dbus.conf  /etc/dbus-1/system.d/

#WORKDIR "/usr/local/src"
#RUN git clone git://git.debian.org/sane/sane-backends.git
#WORKDIR "/usr/local/src/sane-backends"

WORKDIR "/usr/local/src"
RUN wget http://www.sane-project.org/snapshots/sane-backends-git20180906.tar.gz -O sane-backends-git.tar.gz
RUN tar xvzf sane-backends-git.tar.gz && mv backends-* sane-backends-git && cd sane-backends-git; ./configure; make; make install; cd ..;

RUN wget http://www.sane-project.org/snapshots/sane-frontends-git20180906.tar.gz -O sane-frontends-git.tar.gz
RUN tar xvzf sane-frontends-git.tar.gz && mv frontends-* sane-frontends-git && cd sane-frontends-git; ./configure; make; make install; cd ..;

RUN find /usr/lib -name 'libsane-dll.so'

#RUN ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu/ --sysconfdir=/etc --localstatedir=/var  --enable-avahi
#RUN make
#RUN make install

#RUN sane-find-scanner
#RUN scanimage -L

#/bin/bash

RUN mkdir /myApp
WORKDIR /myApp
