#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=coreutils
VERSION="9.2"
SOURCEURL=http://ftp.gnu.org/gnu/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=https://www.gnu.org/software/${PACKAGENAME}/${PACKAGENAME}.html
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
#tar -vxf /i-data/md1/hdd2/COMPILER/finish/${PACKAGENAME}-${VERSION}.tar.xz
cd ${PACKAGENAME}-${VERSION}
#patches="coreutils-i18n.patch \
#	coreutils-i18n-expand-unexpand.patch \
#	coreutils-i18n-cut-old.patch \
#	coreutils-i18n-fix-unexpand.patch \
#	coreutils-i18n-fix2-expand-unexpand.patch \
#	coreutils-i18n-un-expand-BOM.patch \
#	coreutils-i18n-sort-human.patch \
#	coreutils-8.2-uname-processortype.patch \
#	coreutils-overflow.patch"
#for p in $patches
#do
#	wget -nv http://pkgs.fedoraproject.org/cgit/rpms/coreutils.git/plain/"$p"
#	patch -p1 < "$p"
#done

# POSIX requires that programs from Coreutils recognize character boundaries correctly even in multibyte locales.
# The following patch fixes this non-compliance and other internationalization-related bugs. 
#wget -nv http://www.linuxfromscratch.org/patches/downloads/coreutils/${PACKAGENAME}-${VERSION}-i18n-1.patch
#patch -p1 < /i-data/md1/hdd2/COMPILER/finish/${PACKAGENAME}-${VERSION}-i18n-1.patch
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
#autoreconf -vfi
FORCE_UNSAFE_CONFIGURE=1 ./configure \
	--prefix=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--disable-nls \
	--enable-no-install-program=kill,uptime
FORCE_UNSAFE_CONFIGURE=1 colormake
# Run tests
colormake NON_ROOT_USERNAME=nobody check-root
colormake install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
The GNU Core Utilities are the basic file, shell and text manipulation utilities of the GNU operating
system. These are the core utilities which are expected to exist on every operating system. 
License:GPLv3
Version:${VERSION}
Homepage:${HOMEURL}

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
#gendeps ${BUILDDIR}/ffp
# Remove package itself from list of dependencies requirements
#sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
#sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Create profile for ls alias to display characters as is and get colourful lists
mkdir -p ${BUILDDIR}/ffp/etc/profile.d
cat > ${BUILDDIR}/ffp/etc/profile.d/ls.sh << EOF
alias ls='LC_ALL=C ls -hv --color --show-control-chars --quoting-style=shell --group-directories-first'

EOF
chmod 755 ${BUILDDIR}/ffp/etc/profile.d/ls.sh
# Create postinstall script to remove old profile file /ffp/etc/profile.d/ls.sh
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/profile.d/ls.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

prof_file=/ffp/etc/profile.d/ls.sh

if  [ -f \$prof_file.new ] && [ \$(md5sum \$prof_file.new|awk '{print \$1}') = $CHECKSUM ]; then
    mv \$prof_file.new \$prof_file
fi
if  [ -f \$prof_file.new ] && [ \$(md5sum \$prof_file.new|awk '{print \$1}') != $CHECKSUM ]; then
    rm \$prof_file.new
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Move chroot to sbin dir
mkdir -p ${BUILDDIR}/ffp/sbin
mv ${BUILDDIR}/ffp/bin/chroot ${BUILDDIR}/ffp/sbin/
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
#rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Build duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
