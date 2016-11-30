#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

echo "Installing required dependencies"
echo

apt-get -qq install tmux git build-essential autoconf libtool nasm xserver-xorg-dev libxfixes-dev libssl-dev libpam0g-dev libfuse-dev libxrandr-dev -y

git clone git://github.com/neutrinolabs/xrdp
cd xrdp

git submodule init

git submodule update

cd librfxcodec

make

cd ..

cd xorgxrdp/

./bootstrap

./configure

make

make install

cd ..
./bootstrap

./configure --enable-fuse --enable-rfxcodec

make

make install

xrdp-keygen xrdp auto

update-rc.d xrdp defaults
systemctl enable xrdp

cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak.`date +%s` && sed -e s/"\[xrdp1\]"/"\[xrdp0\]\nname=Session Manager\nlib=libxup.so\nusername=ask\npassword=ask\nip=127.0.0.1\nport=-1\nxserverbpp=24\ncode=20\n\n\[xrdp1\]"/g /etc/xrdp/xrdp.ini > /tmp/xrdp.ini.tmp && cp /tmp/xrdp.ini.tmp /etc/xrdp/xrdp.ini

service xrdp start