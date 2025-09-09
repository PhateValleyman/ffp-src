ln -s /ffp/bin/gcc /ffp/bin/arm-linux-gcc
ln -s /ffp/bin/ld /ffp/bin/arm-linux-ld
cd /
mkdir -p /release-build/NSA310/461AFK0b2
cd release-build/NSA310/461AFK0b2
ln -s /mnt/HD_a2/build/trunk/linux-2.6.31.8
cd /mnt/HD_a2/build/v4l-dvb
make install DESTDIR=/i-data/7cf371c4/build/ffp
makepkg v4l-dvb 2.6.31.8_RTL 1

