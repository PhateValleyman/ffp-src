#!/ffp/bin/sh

unset CFLAGS
set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/ffp/home/root/build/script
PACKAGENAME=slapt-get
VERSION="0.10.2t"
SOURCEURL=http://software.jaos.org/source/slapt-get/slapt-get-0.10.2t.tar.gz
HOMEURL=http://software.jaos.org/
#PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
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
# Get source code
wget -nv --no-check-certificate ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.tar.gz
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
# Adapt main info message to ffp
for files in $(grep -Rl 'APT system to Slackware' $PWD | xargs)
do
	sed -i 's|APT system to Slackware|APT system for Fonz Fun Plug (ffp)|g' $files
done
# Adapt all instances of etc var and usr to ffp prefix
for files in $(grep -Rl '/etc' $PWD | xargs)
do
	sed -i 's|/etc|/ffp/etc|g' $files
done
	sed -i 's|etc|ffp/etc|g' Makefile
for files in $(grep -Rl '/var' $PWD | xargs)
do
	sed -i 's|/var|/ffp/var|g' $files
done
for files in $(grep -Rl '/usr' $PWD | xargs)
do
	sed -i 's|/usr|/ffp|g' $files
done
for files in $(grep -Rl '/ffp/ffp' $PWD | xargs)
do
	sed -i 's|/ffp/ffp|/ffp|g' $files
done
# Replace slackware packaging tools with funpkg tool
sed -i 's|/sbin/removepkg |/ffp/bin/funpkg -r |' src/package.h
sed -i 's|/sbin/installpkg |/ffp/bin/funpkg -i |' src/package.h
sed -i 's|/sbin/upgradepkg --reinstall |/ffp/bin/funpkg -u |' src/package.h
# Check available space in /ffp not in root /
sed -i 's|"/"|"/ffp"|' src/transaction.c
# Correct parsing file list of packages
sed -i 's|FILE LIST|ffp/|' src/package.c
# Correct libdir
sed -i '/^LIBDIR=/c\LIBDIR=/ffp/lib' Makefile
# Add ffp repositories to /ffp/etc/slapt-get/slapt-getrc 
sed -i '/^SOURCE=/c\SOURCE=http://downloads.zyxel.nas-central.org/Users/barmalej2/ffp/0.7/arm/packages/:PREFERRED' default.slapt-getrc.arm
# Shared build corrections (add link against libintl)
#sed -i '/^LDFLAGS+=/c\LDFLAGS+=$(CURLFLAGS) -lintl -liconv -lz -lm' Makefile
#
# uClibc Static build corrections
# Slapt-get static build doesn't likes threads-avoid using them even for dependencies-curl, gpg and so on.
# Otherwise it segfaults
#sed -i '/^CURLFLAGS=/c\CURLFLAGS=`curl-config --static-libs`' Makefile
#sed -i '/^LDFLAGS+=/c\LDFLAGS+=$(CURLFLAGS) -lintl -liconv -ldl -lz -lm' Makefile
# uClibc-ng static build corrections
sed -i '/^CURLFLAGS=/c\CURLFLAGS=`curl-config --static-libs`' Makefile
sed -i '/^LDFLAGS+=/c\LDFLAGS+=$(CURLFLAGS) -lintl -liconv' Makefile
# For uClibc-ng disable -fPIC:(Segmentation fault (core dumped)) and enable debug build
sed -i '/^CFLAGS+=$(DEFINES) -fPIC/c\CFLAGS+=$(DEFINES) -fexceptions -gdwarf-2 -gstrict-dwarf' Makefile
exit 0
make static
make staticinstall DESTDIR=${BUILDDIR}
# Shared build
#make
#make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
slapt-get is an APT like system for FFP (fonz fun plug) package management. It allows to search FFP
repositories and third party sources for packages, compare them with installed packages, install new
packages, or upgrade all installed packages. slapt-get is great for scripting as well. It also provides
a framework for dependency resolution for packages that follow the Slackware package format.
License: GPLv2+
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
None. This is a static build.

EOF
#Depends on these packages:
#br2:gcc-solibs br2:uClibc-solibs br2:curl br2:libiconv br2:gettext br2:rtmpdump s:openssl s:zlib
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Move man pages and docs to right place
mv ${BUILDDIR}/ffp/doc ${BUILDDIR}/ffp/share
mv ${BUILDDIR}/ffp/man ${BUILDDIR}/ffp/share
# Add examples of slack-desc slack-required slack-suggests to docs
for files in slack-desc slack-required slack-suggests
do
	cp -a $files ${BUILDDIR}/ffp/share/doc/${PACKAGENAME}-${VERSION}
done
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Add compatibility symlinks of installed and removed packages 
mkdir -p  ${BUILDDIR}/ffp/var/log
ln -s /ffp/funpkg/installed ${BUILDDIR}/ffp/var/log/packages
ln -s /ffp/funpkg/removed ${BUILDDIR}/ffp/var/log/removed-packages
# Correct permissions for shared libraries and libtool library files
if	[ -d ${BUILDDIR}/ffp/lib ]; then
	find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
	find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Generate direct dependencies list for packages.html and slapt-get
#gendeps ${BUILDDIR}/ffp
# Remove package itself from list of dependencies requirements
#for pkgname in ${PACKAGENAME}; do
#	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
#	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
#done
# Add gnupg to list of deps
#sed -i 's|\<uClibc-solibs\>|gnupg uClibc-solibs|' ${BUILDDIR}/install/DEPENDS
#cat >> ${BUILDDIR}/install/slack-required <<- EOF
#gnupg
#EOF

# Remove default config file slapt-getrc and make custom for ffp
rm ${BUILDDIR}/ffp/etc/slapt-get/slapt-getrc
cat > ${BUILDDIR}/ffp/etc/slapt-get/slapt-getrc << 'EOF'
# Working directory for local storage/cache.
WORKINGDIR=/ffp/var/slapt-get

# Exclude package names and expressions.
# To exclude pre and beta packages, add this to the exclude:
#   [0-9\_\.\-]{1}pre[0-9\-\.\-]{1}
#EXCLUDE=^aaa_elflibs,^devs,^glibc-.*,^kernel-.*,^udev,.*-[0-9]+dl$,x86_64,i[3456]86

# Base url to directory with a PACKAGES.TXT.
# slapt-get supported ffp repositories (only last one for now-do not uncomment others):
#SOURCE=rsync://ffp.inreto.de/ffp/0.7/arm/packages/:OFFICIAL
#SOURCE=http://downloads.zyxel.nas-central.org/Users/Mijzelf/FFP-Stick/packages/0.7/arm/:OFFICIAL
#SOURCE=rsync://funplug.wolf-u.li/funplug/0.7/arm/packages/:OFFICIAL
#SOURCE=http://ffp.memiks.fr/pkg/:OFFICIAL
#SOURCE=http://downloads.zyxel.nas-central.org/Users/ariek/ffp/0.7-arm-packages/:OFFICIAL
#SOURCE=http://users.atw.hu/mrdini/packages/:OFFICIAL
SOURCE=http://downloads.zyxel.nas-central.org/Users/barmalej2/ffp/0.7/arm/packages/:PREFERRED

# Packages on a CD/DVD.
# SOURCE=file:///mnt/cdrom/:OFFICIAL

# Home made packages.
# SOURCE=file:///ffp/var/cache/ffp0.7/packages/:CUSTOM

EOF

CHECKSUM_CONF=$(md5sum ${BUILDDIR}/ffp/etc/slapt-get/slapt-getrc|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

DATE=\$(date "+%Y%m%d_%H%M%S")
# Replace slapt-get config file by new version
if	[ -f /ffp/etc/slapt-get/slapt-getrc.new ] && [ \$(md5sum /ffp/etc/slapt-get/slapt-getrc.new|awk '{print \$1}') = $CHECKSUM_CONF ]; then
	if	[ -f /ffp/etc/slapt-get/slapt-getrc ]; then
		mv /ffp/etc/slapt-get/slapt-getrc /ffp/etc/slapt-get/slapt-getrc.old\${DATE}
		mv /ffp/etc/slapt-get/slapt-getrc.new /ffp/etc/slapt-get/slapt-getrc
	else
		mv /ffp/etc/slapt-get/slapt-getrc.new /ffp/etc/slapt-get/slapt-getrc
	fi
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
