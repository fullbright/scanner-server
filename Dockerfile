from ubuntu

RUN apt-get update 
RUN apt-get install -y apt-utils net-tools
RUN apt-get install -y git libconfuse-dev libsane-dev libudev-dev libusb-dev curl build-essential checkinstall pkg-config libdbus-1-dev libdbus-glib-1-dev
RUN apt-get install -y libusb-dev build-essential libsane-dev libavahi-client-dev libavahi-glib-dev vim

RUN apt-get update
RUN apt-get install -y hplip

WORKDIR "/usr/local/src"
RUN git clone https://github.com/mdengler/scanbd.git
WORKDIR "/usr/local/src/scanbd"

RUN ./configure
RUN make all
RUN make install

COPY /usr/local/src/scanbd/scanbd_dbus.conf  /etc/dbus-1/system.d/

WORKDIR "/usr/local/src"
RUN git clone git://git.debian.org/sane/sane-backends.git
WORKDIR "/usr/local/src/sane-backends"

RUN find /usr/lib -name 'libsane-dll.so'

RUN ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu/ --sysconfdir=/etc --localstatedir=/var  --enable-avahi
RUN make
RUN make install

RUN sane-find-scanner
RUN scanimage -L

#/bin/bash