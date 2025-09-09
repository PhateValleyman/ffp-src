#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
export CPPFLAGS="-I/ffp/include -Wno-psabi"
unset CXXFLAGS
unset CFLAGS
SOURCEDIR=/mnt/HD_a2/build
PACKAGENAME=mozjs
VERSION=24.2.0
SOURCEURL=http://ftp.mozilla.org/pub/mozilla.org/js/${PACKAGENAME}-${VERSION}.tar.bz2
HOMEURL=https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget -nv ${SOURCEURL}
tar xjf ${PACKAGENAME}-${VERSION}.tar.bz2
cd ${PACKAGENAME}-${VERSION}
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
cd js/src
./configure --prefix=/ffp --with-arch="armv5te" --disable-debug --enable-optimize --disable-intl-api --enable-strip --enable-install-strip --with-system-nspr --enable-system-ffi --enable-readline --enable-threadsafe --disable-tests
#--enable-optimize="-O3"
make
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "Mozjs is Mozilla's JavaScript engine written in C/C++." >> ${SOURCEDIR}/install/DESCR
echo "It is used in various Mozilla products, including Firefox, and is available under the MPL2." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: br2:libffi br2:nspr br2:ncurses br2:readline s:gcc-solibs s:uClibc-solibs s:zlib" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
# Mozilla JS-correct permissions for headers and pkgconfig file and static library
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.a" -exec chmod 644 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.pc" -exec chmod 644 {} \;
fi
if [ -d ${SOURCEDIR}/ffp/include/mozjs-24 ]; then
   find ${SOURCEDIR}/ffp/include/mozjs-24 -type f -exec chmod -v 644 {} \;
fi
##### Do we really need a static library?
if [ -f ${SOURCEDIR}/ffp/lib/libmozjs-24.a ]; then
   rm ${SOURCEDIR}/ffp/lib/libmozjs-24.a
fi
#####
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
# Create symlinks
cd ${SOURCEDIR}/ffp/bin
ln -s js24 js
ln -s js24-config js-config
cd ${SOURCEDIR}
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/pyload/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/pyload/
fi
if [ ! -d "/ffp/funpkg/additional/pyload/" ]; then
    mkdir -p /ffp/funpkg/additional/pyload/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/pyload/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/pyload/
cd
rm -rf ${SOURCEDIR}