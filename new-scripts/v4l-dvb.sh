#!/ffp/bin/sh

# make -C /lib/modules/2.6.31.8/build SUBDIRS=/i-data/7cf371c4/build/media_build/v4l  modules
set -e
export SHELL="/ffp/bin/sh"
export PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
SOURCEDIR=/mnt/HD_a2/build
HOMEURL=http://www.linuxtv.org
PACKAGENAME=v4l-dvb
VERSION="$(uname -r)_git$(date "+%Y%m%d")"
mkdir -p ${SOURCEDIR}/ffp
# Create symlinks for gcc and linker so they can work with zyxel source
ln -sf /ffp/bin/ar /ffp/bin/arm-linux-ar
ln -sf /ffp/bin/gcc /ffp/bin/arm-linux-gcc
ln -sf /ffp/bin/ld /ffp/bin/arm-linux-ld
cd ${SOURCEDIR}
git clone git://linuxtv.org/media_build.git v4l-dvb
#wget -nv http://gpl.nas-central.org/ZYXEL/NSA310_GPL/FW4.40/build_NSA310.tar.gz
cp -a /mnt/HD_a2/zyxel_gpl/build_NSA310.tar.gz $PWD
tar xf build_NSA310.tar.gz trunk/linux-2.6.31.8
cd trunk/linux-2.6.31.8
cp -a NSA310OBM_Kernel.config .config
make oldconfig
make prepare
make modules_prepare
make modules
# Prepare links to Zyxel's GPL source
mkdir -p /release-build/NSA310/461AFK0b2
cd /release-build/NSA310/461AFK0b2
ln -sf /mnt/HD_a2/build/trunk/linux-2.6.31.8
cd /mnt/HD_a2/build/v4l-dvb
# Add patch to build Realtek rtl2832u module
#sed -i '/\[2.6.31\]/a add v4l-dvb-rtl2832u.patch' backports/backports.txt
#cp -a ${SCRIPTDIR}/v4l-dvb-rtl2832u.patch $PWD/backports/
# Adapt interpreters of scripts to ffp paths
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
./build
make install DESTDIR=${SOURCEDIR}/ffp
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "V4L or Video4Linux is a video capture and output device API and driver framework for the Linux," >> ${SOURCEDIR}/install/DESCR
echo "supporting many USB webcams, TV tuners, and other devices. This package contains of Linux kernel" >> ${SOURCEDIR}/install/DESCR
echo "2.6.31.8 driver modules for V4L-DVB devices" >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires: Zyxel NSA3** series NAS with 2.6.31.8 kernel" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm build_NSA310.tar.gz
rm -rf trunk v4l-dvb
rm /ffp/bin/arm-linux-gcc
rm /ffp/bin/arm-linux-ld
rm -rf /release-build
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages
fi
if [ ! -d "/ffp/funpkg/additional" ]; then
    mkdir -p /ffp/funpkg/additional
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/
cd
#rm -rf ${SOURCEDIR}