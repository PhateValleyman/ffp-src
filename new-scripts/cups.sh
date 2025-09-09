#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
GITBRANCH=1.7
GITURL=http://www.cups.org/cups.git
HOMEURL=http://www.cups.org/
PACKAGENAME=cups
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
git clone -b branch-${GITBRANCH} ${GITURL} ${PACKAGENAME}
cd ${PACKAGENAME}
autoconf
VERSION=`cat config-scripts/cups-common.m4|grep "CUPS_VERSION="|awk -F'"' '{print $2}'`_git`date "+%Y%m%d"`
cp /mnt/HD_a2/ffp0.7arm/scripts/${PACKAGENAME}.patch $PWD/
patch -p1 < ${PACKAGENAME}.patch
aclocal -I config-scripts
autoconf -I config-scripts
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
./configure --prefix=/ffp --with-smbconfig=/etc/samba/smb.conf
make
make install BUILDROOT=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "CUPS is the standards-based, open source printing system developed by Apple Inc. for OS X® and other" >> ${SOURCEDIR}/install/DESCR
echo "UNIX®-like operating systems. CUPS uses the Internet Printing Protocol (IPP) to support printing to" >> ${SOURCEDIR}/install/DESCR
echo "local and network printers." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: uli:dbus-1.6.0 mz:libusb-1.0.9 s:openssl s:uClibc-solibs s:gcc-solibs s:zlib" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}
chmod 755 ${SOURCEDIR}/ffp/var/spool
chmod 755 ${SOURCEDIR}/ffp/etc
echo "ServerName /ffp/var/run/cups/cups.sock" >> ${SOURCEDIR}/ffp/etc/cups/client.conf
touch ${SOURCEDIR}/ffp/etc/cups/{printers.conf,classes.conf,subscriptions.conf}
chgrp nobody ${SOURCEDIR}/ffp/etc/cups/{printers.conf,classes.conf,subscriptions.conf,client.conf}
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
if [ -d ${SOURCEDIR}/ffp/share/gtk-doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/gtk-doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Remove perllocal.pod and .packlist files-this is not local module install
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "perllocal.pod" -exec rm -f {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname ".packlist" -exec rm -f {} \;
fi
#Delete dir, which is side effect of installing
if [ -d ${SOURCEDIR}/ffp/lib/perl5/site_perl/5.14.2/arm-linux-thread-multi-64int/.meta ]; then
    rm -rf ${SOURCEDIR}/ffp/lib/perl5/site_perl/5.14.2/arm-linux-thread-multi-64int/.meta
fi
#adapt executables to FFP prefix again
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
# Move cups startup script to /ffp/start dir
mkdir -p ${SOURCEDIR}/ffp/start
#mv ${SOURCEDIR}/etc/init.d/cups ${SOURCEDIR}/ffp/start/cups.sh
cp -a /ffp/start/cupsd.sh ${SOURCEDIR}/ffp/start/
rm -rf ${SOURCEDIR}/etc
# Create package
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