#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
export CFLAGS="-march=armv5te"
SOURCEDIR=/mnt/HD_a2/build
VERSION=0.9.1
SOURCEURL=http://sourceforge.net/projects/idle3-tools/files/idle3-tools-${VERSION}.tgz
HOMEURL=http://idle3-tools.sourceforge.net/
PACKAGENAME=idle3-tools
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
tar xvzf ${PACKAGENAME}-${VERSION}.tgz
cd ${PACKAGENAME}-${VERSION}
sed -i "/^DESTDIR =/c\DESTDIR = ${SOURCEDIR}" Makefile
sed -i "/^binprefix =/c\binprefix = /ffp" Makefile
sed -i "/^manprefix =/c\manprefix = /ffp" Makefile
sed -i "/^LDFLAGS = -s/c\LDFLAGS = -s ${LDFLAGS}" Makefile
#adapt executables to FFP prefix
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
make
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "Idle3-tools provides a linux/unix utility that can disable, get and set the value of the infamous" >> ${SOURCEDIR}/install/DESCR
echo "idle3 timer found on recent Western Digital Hard Disk Drives. Modern Western Digital HDD's include" >> ${SOURCEDIR}/install/DESCR
echo "the Intellipark feature that stops the disk when not in use. Unfortunately, the default timer setting" >> ${SOURCEDIR}/install/DESCR
echo "is not perfect on linux/unix systems, including many NAS, and leads to a dramatic increase of the Load" >> ${SOURCEDIR}/install/DESCR
echo "Cycle Count value (SMART attribute #193). A power off/on cycle of the drive will still be mandatory for" >> ${SOURCEDIR}/install/DESCR
echo "new settings to be taken into account." >> ${SOURCEDIR}/install/DESCR
echo "Idle3-tools is an independant project, unrelated in any way to Western Digital Corp." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: uClibc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "############################################################" >> ${SOURCEDIR}/install/DESCR
echo "WARNING : THIS SOFTWARE IS EXPERIMENTAL AND NOT WELL TESTED." >> ${SOURCEDIR}/install/DESCR
echo "IT ACCESSES LOW LEVEL INFORMATION OF YOUR HARDDRIVE." >> ${SOURCEDIR}/install/DESCR
echo "USE AT YOUR OWN RISK." >> ${SOURCEDIR}/install/DESCR
echo "Info HOW TO use it on Zyxel NAS'es:" >> ${SOURCEDIR}/install/DESCR
echo "http://forum.nas-central.org/viewtopic.php?f=249&t=7653#p35979" >> ${SOURCEDIR}/install/DESCR
echo "############################################################" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} >> ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/
fi
if [ ! -d "/ffp/funpkg/additional/" ]; then
    mkdir -p /ffp/funpkg/additional/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/
cd
rm -rf ${SOURCEDIR}