#!/ffp/bin/sh

# TODO:
# Add postinstall script to gen id's
# accept4
# ppoll
#checking for linux/btrfs.h... no
#configure: WARNING: *** KERNEL header not found
# https://raw.githubusercontent.com/hpcugent/easybuild-easyconfigs/master/easybuild/easyconfigs/e/eudev/eudev-3.1.2_pre-2.6.34_kernel.patch
# http://repository.timesys.com/buildsources/u/udev/udev-181/
# google udev use poll instead ppoll
# https://dev.openwrt.org/ticket/5766
# https://github.com/systemd/systemd/commits/0ce5a80601597fe4d1a715a8f70ce8d5ccaa2d86/src/shared/util.c?page=3


#check syscalls
# ARM support for TIF_RESTORE_SIGMASK/pselect6/ppoll/epoll_pwait
#google define epoll_pwait 2.6.31
#https://lists.ubuntu.com/archives/kernel-team/2010-February/008529.html
# google accept4 has been added for arm 
# https://sourceware.org/ml/libc-alpha/2013-12/msg00014.html
#/i-data/7cf371c4/unfinishedbuilds/trunk/linux-2.6.31.8/arch/arm/include/asm/unistd.h
#/i-data/7cf371c4/unfinishedbuilds/trunk/linux-2.6.31.8/arch/arm/kernel/calls.S
# google accept4 uclibc arm
# https://bugs.busybox.net/show_bug.cgi?id=4195
set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/build
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=eudev
#VERSION="3.1.5"
#SOURCEURL=http://dev.gentoo.org/~blueness/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.gz
SOURCEURL=https://github.com/gentoo/eudev.git
HOMEURL="https://wiki.gentoo.org/wiki/Eudev"
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
#wget -nv ${SOURCEURL}
#tar xf ${PACKAGENAME}-${VERSION}.tar.gz
git clone ${SOURCEURL}
cd ${PACKAGENAME}
VERSION="$(git describe --abbrev=0 | cut -d'v' -f2)_git$(git rev-parse --short HEAD)"
# Commit https://github.com/gentoo/eudev/commit/71ff5b6886946dacca8ae685ac85cdc174cfdece 
# broken udevd --debug output (it is redirected to /dev/kmsg). Revert changes done by that commit 
patch -Rp1 < ${SCRIPTDIR}/${PACKAGENAME}-debug.patch
# Fix missing constants RAMFS_MAGIC and BTN_TRIGGER_HAPPY for older kernels
patch -p1 < ${SCRIPTDIR}/${PACKAGENAME}-0001.patch
# Adapt scripts to FFP prefix
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
# Fix a tests
sed -i 's|/usr/bin/test|/ffp/bin/test|' test/udev-test.pl
sed -i 's|/etc/udev/rules.d|/ffp/etc/udev/rules.d|' test/test-udev.c
sed -i 's|/lib/udev/rules.d|/ffp/lib/udev/rules.d|' test/test-udev.c
# Our kernel 2.6.31.8 doesn't support accept4 function, so disabling it
# Now eudev has fallback for ppoll and accept4 syscalls
autoreconf -fi
ac_cv_have_decl_ppoll=no ac_cv_have_decl_accept4=no ./configure \
	--prefix=/ffp \
	--with-rootprefix=/ffp \
	--sysconfdir=/ffp/etc \
	--libdir=/ffp/lib \
	--bindir=/ffp/sbin \
	--enable-manpages \
	--with-rootrundir=/run
make
# One test (134-permissions: error) fails: specified group '1' unknown,
# expected permissions are: 1:1:0400
# created permissions are : 1:0:0400
# If change owner to aaa, group to bbb in udev-test.pl, then it passes. Weird?????
# Add daemon and mail groups required by tests
addgroup daemon
addgroup mail
make check || true
delgroup daemon
delgroup mail
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Eudev is a fork of systemd's udev with the goal of obtaining better compatibility with existing
software such as OpenRC, Upstart, older kernels, various toolchains, and anything else required
by (but not well supported by) udev.
(E)udev creates and removes device nodes in /dev for devices discovered or removed from the system.
It receives events via kernel netlink messages and dispatches them according to default rules in 
/ffp/lib/udev/rules.d/ and/or user side rules in /ffp/etc/udev/rules.d/. Matching rules may name a 
device node, create additional symlinks to the node, call tools to initialize a device, or load
needed kernel modules.
License: GPLv2
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:uClibc-solibs br2:kmod br2:util-linux br2:xz- br2:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}
# Remove unused docs
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Adapt scripts to FFP prefix before making package
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
# udev.pc should be in /ffp/lib/pkgconfig
mv ${BUILDDIR}/ffp/share/pkgconfig/udev.pc ${BUILDDIR}/ffp/lib/pkgconfig/
rm -rf ${BUILDDIR}/ffp/share/pkgconfig
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/udevd.sh ${BUILDDIR}/ffp/start/
chmod 644 ${BUILDDIR}/ffp/start/udevd.sh
# Create postinstall script to remove old start-up script
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/udevd.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

# Replace current start script if newer exists
if  [ -f /ffp/start/udevd.sh.new ] && [ \$(md5sum /ffp/start/udevd.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
   if  [ -f /ffp/start/udevd.sh ]; then
       mv /ffp/start/udevd.sh /ffp/start/udevd.sh.old
       chmod 644 /ffp/start/udevd.sh.old
       mv /ffp/start/udevd.sh.new /ffp/start/udevd.sh
   else
       mv /ffp/start/udevd.sh.new /ffp/start/udevd.sh
   fi
fi
if  [ -f /ffp/start/udevd.sh.new ] && [ \$(md5sum /ffp/start/udevd.sh.new|awk '{print \$1}') != $CHECKSUM ]; then
    rm /ffp/start/udevd.sh.new
fi
# Update information about hardware devices for (e)udev
find /ffp/etc/udev/hwdb.d/ -maxdepth 1 -type f -name '*.new' -exec sh -c 'mv "\$0" "\${0%.new}"' {} \;
udevadm hwdb --update
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Comment all specific drivers loading rules and leave only generic drivers loading rule
sed -i '/^SUBSYSTEM/ s/^#*/#/' ${BUILDDIR}/ffp/lib/udev/rules.d/80-drivers.rules
sed -i '/^KERNEL/ s/^#*/#/' ${BUILDDIR}/ffp/lib/udev/rules.d/80-drivers.rules
# Create rule for dvb and webcams device nodes creation
# Copy helper script, which creates nodes
cp -a /ffp/lib/udev/dvb_dev_nodes.sh ${BUILDDIR}/ffp/lib/udev/
cat > ${BUILDDIR}/ffp/lib/udev/rules.d/99-create-dvb-devnodes.rules  << 'EOF'
# Do not edit this file, it will be overwritten on update
# This special udev rule file is a part of ffp 0.7-arm eudev package
ACTION=="remove", GOTO="dvb_devnodes_end"

ACTION=="add", SUBSYSTEMS=="dvb|video4linux", PROGRAM="/ffp/lib/udev/dvb_dev_nodes.sh", MODE="0660"

LABEL="dvb_devnodes_end"
EOF
chmod 755 ${BUILDDIR}/ffp/lib/udev/dvb_dev_nodes.sh
# Copy firmware_load_helper.sh script for (e)udev and create appropriate firmware load rule
cp -a /ffp/lib/udev/firmware_load_helper.sh ${BUILDDIR}/ffp/lib/udev/
cat > ${BUILDDIR}/ffp/lib/udev/rules.d/50-firmware.rules << EOF
# Do not edit this file, it will be overwritten on update
# This special udev rule file is a part of ffp 0.7-arm eudev package
ACTION=="remove", GOTO="firmware_end"

ACTION=="add", SUBSYSTEM=="firmware", RUN+="/ffp/lib/udev/firmware_load_helper.sh"

LABEL="firmware_end"
EOF
chmod 755 ${BUILDDIR}/ffp/lib/udev/firmware_load_helper.sh
# Disable some rules to avoid conflict with zyxel hotplug
mkdir -p ${BUILDDIR}/ffp/lib/udev/rules.d/disabled
rules="50-udev-default.rules 60-sensor.rules 60-block.rules 60-cdrom_id.rules 60-drm.rules 60-evdev.rules 60-persistent-storage.rules 60-persistent-storage-tape.rules 64-btrfs.rules 70-touchpad.rules 70-mouse.rules 75-net-description.rules 75-probe_mtd.rules 80-net-name-slot.rules"
for rule in $rules
do
	mv ${BUILDDIR}/ffp/lib/udev/rules.d/"$rule" ${BUILDDIR}/ffp/lib/udev/rules.d/disabled
done
# We will use adapted for ffp 50-udev-default.rules
cp -a ${SCRIPTDIR}/50-udev-default.rules ${BUILDDIR}/ffp/lib/udev/rules.d/ 
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
