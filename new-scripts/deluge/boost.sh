#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
CPPFLAGS="$CPPFLAGS -Wno-unused-variable -Wno-unused-function -Wno-deprecated-declarations -Wno-unused-local-typedefs -fno-strict-aliasing"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=boost
VERSION="1.63.0"
SOURCEURL=http://downloads.sourceforge.net/${PACKAGENAME}/${PACKAGENAME}_${VERSION//./_}.tar.bz2
HOMEURL=http://www.boost.org/
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/deluge"
PKGDIRBACKUP="/ffp/funpkg/additional/deluge"
export PKGDIR PATH CPPFLAGS
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
wget -nv ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.bz2
tar xf ${PACKAGENAME}-${VERSION}.tar.bz2 --transform=s"|${PACKAGENAME}_${VERSION//./_}|${PACKAGENAME}-${VERSION}|"
cd ${PACKAGENAME}-${VERSION}
# Apply patch to support dynamic linking on other plaftorms than windows
# Fixes libtorrent libraries linking to boost libs issue (can't resolve symbols),
# when compile flags "-fvisibility=hidden -fvisibility-inlines-hidden" is used (since r10294-20140912 in libtorrent)
# http://code.google.com/p/libtorrent/issues/detail?id=697&can=1&sort=-id
# https://github.com/boostorg/asio/pull/1
#cp -a ${SCRIPTDIR}/${PACKAGENAME}.patch $PWD/
#patch -p1 < ${SCRIPTDIR}/${PACKAGENAME}1.patch
#Solve error 'FE_INEXACT' was not declared in this scope
#https://svn.boost.org/trac/boost/ticket/11756
#wget https://svn.boost.org/trac/boost/raw-attachment/ticket/11756/0001-execution_monitor-fix-soft-float-issues.2.patch -O ${PACKAGENAME}2.patch
#patch -p2 < ${PACKAGENAME}2.patch
#
#
####### Look for upstream patches here #######
# http://www.boost.org/patches
# Apply buildroot patches to adapt boost source to uClibc
wget -e robots=off -nv -np -nd -H -r --level=1 -A patch https://git.buildroot.net/buildroot/plain/package/boost/
# The following patch is implemented upstream
rm 0004-fix-getchar-with-uclibc-and-gcc-bug-58952.patch
for patches in ????-*.patch
do
    patch -p1 < $patches
done
# OLD PROBLEM https://svn.boost.org/trac/boost/ticket/11756 arises again in boost 1.63.0 
# Temporary solution
wget "https://raw.githubusercontent.com/Entware-ng/entware-packages/master/libs/boost/patches/520-test-BOOST_NO_FENV_H.patch" -O 1.patch
patch -p1 < 1.patch
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
# http://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
# http://lists.boost.org/boost-users/2010/07/60682.php
# http://www.boost.org/doc/libs/1_51_0/libs/locale/doc/html/building_boost_locale.html
# Resolve warning:incompatible implicit declaration of built-in function 'strndup' (not needed with new toolchain)
# sed -i '/^#include "jam.h"/i\#define _GNU_SOURCE' tools/build/v2/engine/jam.c
#
# Support for OpenMPI
echo "using mpi ;" >> tools/build/src/user-config.jam
./bootstrap.sh \
	--prefix=/ffp \
	--with-icu=/ffp
# Adapt executables to FFP prefix after bootstraping
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
# boost.locale.posix needs monetary.h which isn't available on uClibc, so disable it.
# Build stage
#./b2 cxxflags="$CPPFLAGS $CXXFLAGS -std=c++11" cflags="$CPPFLAGS $CFLAGS" linkflags="$LDFLAGS" stage \
#	threading=multi \
#	link=shared \
#	boost.locale.winapi=off \
#	boost.locale.posix=off
# Install stage
./b2 cxxflags="$CPPFLAGS $CXXFLAGS -std=gnu++98 -fPIC" cflags="$CPPFLAGS $CFLAGS -fPIC" linkflags="$LDFLAGS" install \
	--prefix=${BUILDDIR}/ffp \
	variant=release \
	threading=multi \
	link=shared \
	runtime-link=shared \
	boost.locale.winapi=off \
	boost.locale.posix=off
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Boost provides a set of free peer-reviewed portable C++ source libraries. It includes libraries for
linear algebra, pseudorandom number generation, multithreading, image processing, regular expressions
and unit testing.
License: BSL-Boost Software License (Open Source Initiative certified)
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
gcc-solibs icu4c libiconv openmpi python-2.7.* uClibc-solibs bzip2 zlib

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
sed -i "s| \<${PACKAGENAME}\>||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Add python-2.7.*, icu4c, openmpi and to list of deps (new openmpi and icu4c packages are not yet uploaded to repo)
sed -i '1 s|$| icu4c python-2.7.* openmpi|' ${BUILDDIR}/install/DEPENDS
cat >> ${BUILDDIR}/install/slack-required <<- EOF
icu4c
openmpi
python >= 2.7.13-arm-1
python < 2.8.0
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
