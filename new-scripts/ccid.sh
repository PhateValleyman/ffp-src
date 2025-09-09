#!/ffp/bin/sh

# https://ludovicrousseau.blogspot.com/2011/11/pcscd-auto-start-using-systemd.html
# https://ludovicrousseau.blogspot.com/2010/12/configuring-your-system-for-pcscd-auto.html
# https://www.apt-browse.org/browse/debian/wheezy/main/i386/libccid/1.4.7-1/file/lib/udev/rules.d/92-libccid.rules
# https://gitweb.gentoo.org/repo/gentoo.git/plain/app-crypt/ccid/files/92_pcscd_ccid-2.rules
# 92-libccid.rules is shipped with ccid package. We are using old way to start pcscd service (no systemd)
# So we need to use old style rule. Gentoo and Wheezy has it. Gentoo rule is a bit better, as it has power support for older kernels.
# I will use it, but instead of passing ENV{PCSCD}="1" to another 99-pcscd-hotplug.rule, I will change to GROUP="pcscd" like Wheezy does.

set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=ccid
VERSION="1.4.26"
SOURCEURL=https://alioth.debian.org/frs/download.php/file/4205/${PACKAGENAME}-${VERSION}.tar.bz2
HOMEURL=http://pcsclite.alioth.debian.org/ccid.html
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
wget -nv ${SOURCEURL}
tar xf "${SOURCEURL##*/}"
cd ${PACKAGENAME}-${VERSION}
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
./configure \
	--prefix=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--enable-twinserial
make
make install DESTDIR=${BUILDDIR}
cd contrib
make
mkdir -p ${BUILDDIR}/ffp/bin
cp -a RSA_SecurID/RSA_SecurID_getpasswd ${BUILDDIR}/ffp/bin
cp -a Kobil_mIDentity_switch/Kobil_mIDentity_switch ${BUILDDIR}/ffp/bin
cd ..
# Make symlink for configuration file in /ffp/etc/ccid
mkdir -p ${BUILDDIR}/ffp/etc/ccid
if	[ ! -r /ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist ]
then
	mkdir -p /ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents
	cp -a ${BUILDDIR}/ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist /ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents/
	ln -s /ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist ${BUILDDIR}/ffp/etc/ccid/Info.plist
	rm /ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist
else
	ln -s /ffp/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Info.plist ${BUILDDIR}/ffp/etc/ccid/Info.plist
fi
# Copy rules file
# Use gentoo rule instead shipped one with ccid
#sed -i 's|\/usr\/sbin|\/ffp\/bin|g' src/92_pcscd_ccid.rules
#sed -i 's|\/bin\/sh|\/ffp\/bin\/sh|g' src/92_pcscd_ccid.rules
mkdir -p ${BUILDDIR}/ffp/lib/udev/rules.d
#cp -a src/92_pcscd_ccid.rules ${BUILDDIR}/ffp/lib/udev/rules.d/
wget -nv https://gitweb.gentoo.org/repo/gentoo.git/plain/app-crypt/ccid/files/92_pcscd_ccid-2.rules -O ${BUILDDIR}/ffp/lib/udev/rules.d/92_pcscd_ccid.rules
sed -i 's|\/usr\/sbin|\/ffp\/bin|g' ${BUILDDIR}/ffp/lib/udev/rules.d/92_pcscd_ccid.rules
sed -i 's|\/bin\/sh|\/ffp\/bin\/sh|g' ${BUILDDIR}/ffp/lib/udev/rules.d/92_pcscd_ccid.rules
sed -i 's|ENV{PCSCD}="1"|GROUP="pcscd"|g' ${BUILDDIR}/ffp/lib/udev/rules.d/92_pcscd_ccid.rules
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
This package provides generic driver for USB CCID (Chip/Smart Card Interface Devices)
and  ICCD (Integrated Circuit(s) Card Devices).
License: LGPLv2.1+
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Add additional dependencies
sed -i '1 s|$| eudev pcsc-lite|' ${BUILDDIR}/install/DEPENDS
cat >> ${BUILDDIR}/install/slack-required <<- EOF
eudev
pcsc-lite
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"