#!/ffp/bin/sh

set -e
export CPPFLAGS="-I/ffp/include"
export CFLAGS="-I/ffp/include"
export CXXFLAGS="-I/ffp/include"
export LDFLAGS="-L/ffp/lib"
export LIBRARY_PATH="/ffp/lib"
export SHELL="/ffp/bin/sh"
################################IMPORTANT:##############################################
# kernel-headers package is conflicting with uclibc headers.
# /ffp/include/linux/kernel.h from kernel-headers and /ffp/include/sys/sysinfo.h from
# uClibc has the same function-"struct sysinfo" declared. I removed struct sysinfo
# declarations from uClibc-/ffp/include/sys/sysinfo.h, before compiling final gcc 
# version. Additionally I got some errors regarding missing SCSI functions declarations.
# Again it is the conflict between these packages. /ffp/include/scsi/scsi.h header exist
# in both packages, but only uClibc provided scsi.h has all necessary functions defined.
# In case, this file was overwritten by kernel-headers provided scsi.h, reinstall of
# uClibc is highly recommended before proceeding to compile gcc.
########################################################################################
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
GNU_TARGET=$GNU_HOST
BUILDDIR=/mnt/HD_a2/build
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=gcc
VERSION=4.9.2
SOURCEURL=ftp://gcc.gnu.org/pub/gcc/releases/${PACKAGENAME}-${VERSION}/${PACKAGENAME}-${VERSION}.tar.bz2
HOMEURL=https://gcc.gnu.org/
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create buildir and download source code
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
wget -nv ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.tar.bz2
cd ${PACKAGENAME}-${VERSION}
# Apply patches to adapt for uClibc
for p in ${SCRIPTDIR}/patches/*.patch; do
	cp -a $p $PWD/
	patch -p1 < $p
done
# Fix a problem identified upstream 4.9.1?:
#sed -i 's/if \((code.*))\)/if (\1 \&\& \!DEBUG_INSN_P (insn))/' gcc/sched-deps.c
# Startfiles in /ffp/lib/
echo  '#undef STANDARD_STARTFILE_PREFIX_1'             >>gcc/config/linux.h
echo '#define STANDARD_STARTFILE_PREFIX_1 "/ffp/lib/"' >>gcc/config/linux.h
echo  '#undef STANDARD_STARTFILE_PREFIX_2'             >>gcc/config/linux.h
echo '#define STANDARD_STARTFILE_PREFIX_2 ""'          >>gcc/config/linux.h
# Dynamic linker in /ffp/lib/
sed -i '/UCLIBC_DYNAMIC_LINKER/ s,/lib/,/ffp&,' gcc/config/linux.h
# Adapt scripts to FFP prefix
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
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
mkdir $PWD/../gcc-build
cd $PWD/../gcc-build
$PWD/../${PACKAGENAME}-${VERSION}/configure \
			--build=$GNU_BUILD \
			--host=$GNU_HOST \
			--target=$GNU_TARGET \
			--prefix=/ffp \
			--with-local-prefix=/ffp \
			--with-native-system-header-dir=/ffp/include \
			--disable-nls \
			--enable-shared \
			--enable-languages=c,c++ \
			--enable-__cxa_atexit \
			--enable-threads=posix \
			--disable-multilib \
			--with-system-zlib \
			--enable-clocale=gnu \
			--enable-c99 \
			--enable-long-long \
			--disable-decimal-float \
			--with-float=soft \
			--disable-docs \
			--enable-checking=release
# These two options are used for quick compile of gcc (5hours :)), just for preliminary testing purpose
#			--disable-bootstrap \
#			--enable-checking=no
# Adapt scripts to FFP prefix after configuration
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
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
make
#make check (interesting how much time it can take on NSA310? Month?)
make DESTDIR=${BUILDDIR} install
# Create compatibility symlink 
ln -s gcc ${BUILDDIR}/ffp/bin/cc
# Move the misplaced file:
mkdir -p ${BUILDDIR}/ffp/share/gdb/auto-load
mv ${BUILDDIR}/ffp/lib/*-gdb.py ${BUILDDIR}/ffp/share/gdb/auto-load
# Description for full gcc package
mkdir -p ${BUILDDIR}/install
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
GCC GNU Compiler Collection is an open source command-line software designed to act as
a compiler for GNU/Linux and BSD-based operating systems. It includes front-ends for 
numerous programming languages, including C, C++, Objective-C, Fortran, Java, Ada, and Go,
as well as libraries for these languages.With GCC you can configure, compile and install 
GNU/Linux applications in Linux or BSD operating systems using the source archive of the 
respective program.
NOTE:This package contains only the C and C++ compilers.
License(s):GNU GPLv3+ with GCC Runtime Library Exception, FDLv1.3
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:gcc-solibs br2:uClibc br2:uClibc-solibs br2:libiconv br2:gmp br2:mpfr br2:mpc

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
# Remove unnecessary stuff
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Create solibs package first
mkdir -p ${PACKAGENAME}-solibs/ffp/lib
cp -av ${BUILDDIR}/ffp/lib/*.so* ${PACKAGENAME}-solibs/ffp/lib/
# Description for gcc-solibs 
mkdir -p ${PACKAGENAME}-solibs/install
cat > ${BUILDDIR}/${PACKAGENAME}-solibs/install/DESCR << EOF

Description of gcc-solibs:
GCC GNU Compiler Collection is an open source command-line software designed to act as
a compiler for GNU/Linux and BSD-based operating systems. It includes front-ends for.
numerous programming languages, including C, C++, Objective-C, Fortran, Java, Ada, and Go,
as well as libraries for these languages.With GCC you can configure, compile and install.
GNU/Linux applications in Linux or BSD operating systems using the source archive of the.
respective program.
NOTE:This package contains the shared libraries of gcc-libgcc, libssp, libstdc++ and so on.
License(s):GNU GPLv3+ with GCC Runtime Library Exception, FDLv1.3 
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:gcc br2:uClibc br2:uClibc-solibs

EOF
echo ${HOMEURL} >  ${PACKAGENAME}-solibs/install/HOMEPAGE
cd ${PACKAGENAME}-solibs
makepkg ${PACKAGENAME}-solibs ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/gcc" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/gcc
fi
if [ ! -d "/ffp/funpkg/additional/gcc" ]; then
    mkdir -p /ffp/funpkg/additional/gcc
fi
cp /tmp/${PACKAGENAME}-solibs-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/gcc/
mv /tmp/${PACKAGENAME}-solibs-${VERSION}-arm-1.txz /ffp/funpkg/additional/gcc/
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Adapt scripts to FFP prefix before making package
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
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
makepkg ${PACKAGENAME} ${VERSION} 1
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/gcc/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/gcc/
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"