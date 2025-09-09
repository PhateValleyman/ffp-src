#!/ffp/bin/bash

set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
SHELL="/ffp/bin/bash"
PATH="/ffp/bin:/ffp/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/build
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=binutils
VERSION=2.28
SOURCEURL=http://ftp.gnu.org/gnu/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=http://www.gnu.org/software/binutils
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/gcc"
PKGDIRBACKUP="/ffp/funpkg/additional/gcc"
ELF_DYNAMIC_INTERPRETER=\"/ffp/lib/ld-uClibc.so.0\"
ELF_INTERPRETER_NAME=\"/ffp/lib/ld-uClibc.so.0\"
export ELF_INTERPRETER_NAME ELF_DYNAMIC_INTERPRETER SHELL PATH PKGDIR 
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
tar xzf ${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}-${VERSION}
# Get and apply patches
#wget -e robots=off -nv -np -nd -r --level=1 -A patch http://git.buildroot.net/buildroot/plain/package/binutils/2.24/
#wget -nv "https://projects.archlinux.org/svntogit/packages.git/plain/trunk/binutils-2.24-lto-testsuite.patch?h=packages/binutils" -O 1.patch
#wget -nv "https://projects.archlinux.org/svntogit/packages.git/plain/trunk/binutils-2.24-shared-pie.patch?h=packages/binutils" -O 2.patch
#wget -nv "http://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=patch;h=10fe779dd24e3809070b5b634214a9c7d8b11814" -O 3.patch
#wget -nv "http://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=patch;h=a2d010462ce99a4fc79fb19c31915f86fafeea43" -O 4.patch
#wget -nv "http://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=patch;h=0ef76c43d739e436ad7f1cccd253cc5713d2d63d" -O 5.patch
#for patches in *.patch; do
#    patch -p1 < $patches
#done
#for patches in ${SCRIPTDIR}/${PACKAGENAME}*.patch; do
#    cp -a $patches $PWD/
#    patch -p1 < $patches
#done
# Fix build with gcc 4.9.*
# http://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=commit;h=27b829ee701e29804216b3803fbaeb629be27491
#wget -nv "http://pkgs.fedoraproject.org/cgit/binutils.git/plain/binutils-2.24-set-section-macros.patch" -O 6.patch
#patch -p0 < 6.patch
# Suppress the installation of an outdated standards.info
#rm -fv etc/standards.info
#sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in
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
# Change hardcoded elf interpreter, dynamic linker
sed -i 's|/usr/lib/libc.so.1|/ffp/lib/ld-uClibc.so.0|g' gold/arm.cc
sed -i 's|/usr/lib/ld.so.1|/ffp/lib/ld-uClibc.so.0|g' bfd/elf32-arm.c
# Force look for a /ffp/etc/ld.so.conf instead of firmware /etc/ld.so.conf
sed -i 's|/etc/ld.so.conf|/ffp/etc/ld.so.conf|g' {binutils,zlib,gas,opcodes,bfd,gprof,ld}/configure ltmain.sh libtool.m4
#sed -i 's|ld_sysroot, "/etc/ld.so.conf"|ld_sysroot, "/ffp/etc/ld.so.conf"|' ld/emultempl/elf32.em
mkdir -v ../binutils-build
cd ../binutils-build
../${PACKAGENAME}-${VERSION}/configure \
	--prefix=/ffp \
	--with-lib-path=/ffp/lib \
	--with-build-sysroot=/ffp \
	--with-sysroot=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--target=$GNU_HOST \
	--enable-gold \
	--enable-ld=default \
	--enable-shared \
	--enable-threads \
	--enable-plugins \
	--disable-nls \
	--disable-multilib \
	--disable-werror \
	--disable-gdb \
	--disable-sim \
	--with-system-zlib
# Adapt scripts to FFP prefix after configuration
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
make tooldir=/ffp
# unset LDFLAGS as testsuite makes assumptions about which ones are active
# ignore failures on gold testsuite
# Disable make check, too processor/ram intensive, blows up
#make -k LDFLAGS="" check || true
make tooldir=/ffp DESTDIR=${BUILDDIR} install
mkdir -p ${BUILDDIR}/install
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Binutils is the set of tools to assemble and manipulate binary and object files
The main ones are:
* ld - the GNU linker
* as - the GNU assembler
License(s): GPLv3+
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
gcc gcc-solibs uClibc-ng uClibc-ng-solibs zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unnecessary stuff
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
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
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"