#!/ffp/bin/sh

# make -C /lib/modules/${KERNEL_VERSION}/build SUBDIRS=/i-data/7cf371c4/build/media_build/v4l  modules

set -e
SHELL="/ffp/bin/sh"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
#ccflags="-Wno-unused-but-set-variable -Wno-unused-variable"
BUILDDIR=/mnt/HD_a2/build
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=v4l-dvb
VERSION="$(uname -r)_gitc3e8bd6"
SOURCEURL="git://linuxtv.org/media_build.git"
HOMEURL="http://www.linuxtv.org"
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
KERNEL_VERSION="$(uname -r)"
export SHELL PKGDIR PATH ccflags
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR}/ffp ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
# Extract and prepare Zyxel GPL sources (linux kernel ${KERNEL_VERSION})
# Create symlinks for gcc and linker so they can work with zyxel source
ln -sf /ffp/bin/ar /ffp/bin/arm-linux-ar
ln -sf /ffp/bin/gcc /ffp/bin/arm-linux-gcc
ln -sf /ffp/bin/ld /ffp/bin/arm-linux-ld
#wget -nv http://gpl.nas-central.org/ZYXEL/NSA310_GPL/FW4.40/build_NSA310.tar.gz
cp -a /mnt/HD_a2/zyxel_gpl/build_NSA310.tar.gz $PWD
tar xf build_NSA310.tar.gz trunk/linux-${KERNEL_VERSION}
cd trunk/linux-${KERNEL_VERSION}
cp -a NSA310OBM_Kernel.config .config
make oldconfig
make prepare
make modules_prepare
make modules
# Prepare links to Zyxel's GPL source
mkdir -p /release-build/NSA310/461AFK0b2
cd /release-build/NSA310/461AFK0b2
ln -sf ${BUILDDIR}/trunk/linux-${KERNEL_VERSION}
# Get source
# Since commit (2014-06-12) http://git.linuxtv.org/media_tree.git?a=commitdiff;h=0c4348ada001181637b8f73482242166ba2fb56e
# preprocessor macro "lockdep_assert_held" is used to build linux drivers with media_build
# It not available on 2.6.31.8 kernel and was introduced only since 2.6.32
# http://permalink.gmane.org/gmane.comp.video.linuxtv.scm/19675
# I will use older (2.6.31.* compatible) 2014-05-24 media_build source (commit c3e8bd66491a0eaf75a9bb48dbfa649f8b76f584)
# and corresponding linux drivers (linux-media-2014-05-21-f7a27ff.tar.bz2) from:
# https://www.linuxtv.org/downloads/drivers/
cd ${BUILDDIR}
git clone ${SOURCEURL} ${PACKAGENAME}
cd ${PACKAGENAME}
git checkout c3e8bd66491a0eaf75a9bb48dbfa649f8b76f584
# Adapt scripts to /ffp prefix
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
### Enable uvcvideo.ko module build in 2.6.31 kernel (not working)
#sed -i '/^USB_VIDEO_CLASS/d' v4l/versions.txt
#sed -i '/^\[2.6.31\]/a USB_VIDEO_CLASS' v4l/versions.txt
cd linux
# Disable emmiting messages in kernel ring buffer:
# WARNING: You are using an experimental version of the media stack.
# As the driver is backported to an older kernel, it doesn't offer enough quality for its usage in production.
sed -i 's|^patch_file|#patch_file|' version_patch.pl
# Download linux drivers, correspinding to media_build commit date
wget -nv http://www.linuxtv.org/downloads/drivers/linux-media-2014-05-21-f7a27ff.tar.bz2
tar xf linux-media-2014-05-21-f7a27ff.tar.bz2
# Apply patch to include Realtek rtl2832u module
# As a base of rtl2832u driver with Rafael Micro R820T tuner support, was used patch dvb-usb-rtl2832_kernel_3.6.tar.gz from:
# http://forums.openpli.org/topic/20899-rtl2832u-chipset-support-proposal/?view=findpost&p=330429
# Build instructions:
# http://forums.openpli.org/topic/20899-rtl2832u-chipset-support-proposal/?view=findpost&p=339988
# For older than 2.2.2. realtek drivers build fix, this post was particularly usefull:
# http://forums.openpli.org/topic/20899-rtl2832u-chipset-support-proposal/?view=findpost&p=330103
patch -p1 < ${SCRIPTDIR}/${PACKAGENAME}-usb-rtl2832.patch
# Enable Genius i-Look 317 support
sed -i $'/^\t{USB_DEVICE(0x093a, 0x2622)*/a\\\t{USB_DEVICE(0x093a, 0x2623), .driver_info = FL_VFLIP},' drivers/media/usb/gspca/pac7302.c
cd "$PWD"/..
make KERNELRELEASE="${KERNEL_VERSION}"
# Disable depmod run during install
sed -i '/^[^#].*depmod/s/^/#/' v4l/Makefile.media
# Install drivers and firmware to updates dirs
make KERNELRELEASE="${KERNEL_VERSION}" KDIR26="/lib/modules/${KERNEL_VERSION}/updates" \
	DESTDIR="${BUILDDIR}/ffp" FW_DIR="${BUILDDIR}/ffp/lib/firmware/updates/" install
#make install DESTDIR=${BUILDDIR}/ffp
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
V4L or Video4Linux is a video capture and output device API, driver framework for the Linux,
supporting many USB webcams, TV tuners, and other devices. This package contains Linux kernel
${KERNEL_VERSION} driver modules for V4L and DVB devices.
License: GPL
Version:${VERSION}
Homepage:${HOMEURL}

Requires: Zyxel NSA3** series NAS with ${KERNEL_VERSION} kernel
Depends on these packages:
br2:eudev br2:kmod

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm build_NSA310.tar.gz
rm -rf trunk v4l-dvb
rm /ffp/bin/arm-linux-ar /ffp/bin/arm-linux-gcc /ffp/bin/arm-linux-ld
rm -rf /release-build
# Decleare dependencies to load modules, for packages.html and slapt-get
echo "eudev kmod" > ${BUILDDIR}/install/DEPENDS
echo "eudev" > ${BUILDDIR}/install/slack-required
echo "kmod" >> ${BUILDDIR}/install/slack-required
# Create postinstall script to regenerate modules database.
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

if	[ -x /ffp/sbin/depmod ]
then
	if	[ -f  /ffp/funpkg/installed/kmod-*-arm-* ]
	then
		/ffp/sbin/depmod -a
	else
		echo "Uninstall manually outdated module_utils package and install replacement package-kmod"
	fi
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Get firmware
cd ${BUILDDIR}/ffp/lib/firmware/updates
git clone https://github.com/OpenELEC/dvb-firmware
cp -a dvb-firmware/firmware/* $PWD
rm -rf dvb-firmware
wget -nv http://www.linuxtv.org/downloads/firmware/dvb-firmwares.tar.bz2
tar xf dvb-firmwares.tar.bz2
rm v4l-cx23885-enc.fw dvb-firmwares.tar.bz2 
mv README.as102 LICENCE.as102_data

# Bypass stripping for now. Not much reduces and might appear unwanted side effects.
# Strip modules
#cd ${BUILDDIR}/ffp/lib/modules
#find "$PWD" -type f -iname "*.ko" -exec strip --strip-unneeded {} \;

cd ${BUILDDIR}
# Create config file for modprobe rtl2832u dvb dongle
mkdir -p ${BUILDDIR}/ffp/lib/modprobe.d
cat > ${BUILDDIR}/ffp/lib/modprobe.d/dvb-usb-rtl2832.conf << EOF
# /ffp/lib/modprobe.d/dvb-usb-rtl2832.conf
# This file is a part of v4l-dvb ffp package
# Disable default NEC remote mode, which results sluggish input in command line (weird)
# You may want to experiment with other possible remote modes: 
# 0=rc6, 1=rc5, 2=nec, 3=disable rc, default=2
options dvb-usb-rtl2832 rtl2832u_rc_mode=3

EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"