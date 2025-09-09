#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
VERSION=3.02.02
SOURCEURL=http://tesseract-ocr.googlecode.com/files/tesseract-ocr-${VERSION}.tar.gz
HOMEURL=http://code.google.com/p/tesseract-ocr
PACKAGENAME=tesseract-ocr
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget -nv ${SOURCEURL}
tar xzf ${PACKAGENAME}-${VERSION}.tar.gz
mv ${PACKAGENAME} ${PACKAGENAME}-${VERSION}
cd ${PACKAGENAME}-${VERSION}
#sed -i '1,1i#include <unistd.h>' viewer/svutil.cpp
#sed -i '1,1i#include <stdarg.h>' ccutil/serialis.cpp
sed -i '/stat.h>/a\#include <stdarg.h>' ccutil/scanutils.h
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
autoreconf -if
#adapt executables to FFP prefix after autoreconf
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
LIBLEPT_HEADERSDIR=/ffp/include/leptonica ./configure --prefix=/ffp --enable-shared --disable-static --enable-embedded
#LIBLEPT_HEADERSDIR=/ffp/include/leptonica ./configure --prefix=/ffp --with-extra-libraries=/ffp/lib --enable-embedded
make
make check
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "Tesseract is probably the most accurate open source OCR engine available." >> ${SOURCEDIR}/install/DESCR
echo "Combined with the Leptonica Image Processing Library it can read a wide variety" >> ${SOURCEDIR}/install/DESCR
echo "of image formats and convert them to text in over 60 languages" >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: br2:leptonica s:giflib s:libjpeg s:libpng br2:libtiff br2:libwebp" >> ${SOURCEDIR}/install/DESCR 
echo "                         s:zlib s:uClibc-solibs s:gcc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "############################################################################################" >> ${SOURCEDIR}/install/DESCR
echo "NOTE!!! English, german, french and russian language training data is included this package." >> ${SOURCEDIR}/install/DESCR
echo "If you need more download them from: http://code.google.com/p/tesseract-ocr/downloads/list," >> ${SOURCEDIR}/install/DESCR
echo "extract and copy content-all files from archive tessdata directory to /ffp/share/tessdata " >> ${SOURCEDIR}/install/DESCR
echo "############################################################################################" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
wget http://${PACKAGENAME}.googlecode.com/files/${PACKAGENAME}-3.02.eng.tar.gz
tar xf ${PACKAGENAME}-3.02.eng.tar.gz
wget http://${PACKAGENAME}.googlecode.com/files/${PACKAGENAME}-3.02.deu.tar.gz
tar xf ${PACKAGENAME}-3.02.deu.tar.gz
wget http://${PACKAGENAME}.googlecode.com/files/${PACKAGENAME}-3.02.fra.tar.gz
tar xf ${PACKAGENAME}-3.02.fra.tar.gz
wget http://${PACKAGENAME}.googlecode.com/files/${PACKAGENAME}-3.02.rus.tar.gz
tar xf ${PACKAGENAME}-3.02.rus.tar.gz
cp -ar ${SOURCEDIR}/${PACKAGENAME}/tessdata ${SOURCEDIR}/ffp/share
rm -rf ${SOURCEDIR}/${PACKAGENAME}*
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