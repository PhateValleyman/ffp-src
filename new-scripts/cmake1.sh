#!/ffp/bin/sh

set -e
export PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export CFLAGS="$CPPFLAGS $CFLAGS"
export CXXFLAGS="$CPPFLAGS $CXXFLAGS"
#export CMAKE_SYSTEM_PREFIX_PATH=/ffp
#export CMAKE_PREFIX_PATH=/ffp
export CMAKE_INSTALL_PREFIX=/ffp
#export CMAKE_SYSROOT=/ffp
#export CMAKE_FIND_ROOT_PATH=/ffp
#export CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=only
#export CMAKE_FIND_ROOT_PATH_MODE_LIBRARY=only
#export CMAKE_FIND_ROOT_PATH_MODE_PACKAGE=only
#export CMAKE_FIND_ROOT_PATH_MODE_PROGRAM=only
#GNU_BUILD=arm-ffp-linux-uclibcgnueabi
#GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=cmake
VERSION=3.1.2
SOURCEURL=http://www.cmake.org/files/v3.1/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=http://www.cmake.org
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
cd ${PACKAGENAME}-${VERSION}
make
#make check
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
CMake is an extensible, open-source system that manages the build process in an operating system
and in a compiler-independent manner. Unlike many cross-platform systems, CMake is designed to be
used in conjunction with the native build environment. Simple configuration files placed in each
source directory (called CMakeLists.txt files) are used to generate standard build files
License:OSI-approved BSD 3-clause License
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:uClibc br2:uClibc-solibs br2:gcc/gcc br2:gcc-solibs br2:curl br2:expat br2:ncurses
s:bzip2 uli:zlib s:xz-5.*

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
# Adapt scripts to FFP prefix again, before making package
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
cd ${BUILDDIR}
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages
fi
if [ ! -d "/ffp/funpkg/additional" ]; then
    mkdir -p /ffp/funpkg/additional
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"