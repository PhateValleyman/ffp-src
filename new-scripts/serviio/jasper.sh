#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
SOURCEURL=http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
HOMEURL=http://www.ece.uvic.ca/~frodo/jasper/
PACKAGENAME=jasper
VERSION=`echo ${SOURCEURL}|awk -F'-' '{print $2}'|cut -f1,2,3 -d'.'`
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
unzip ${PACKAGENAME}-${VERSION}.zip
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
wget http://www.linuxfromscratch.org/patches/blfs/svn/jasper-1.900.1-security_fixes-1.patch
patch -Np1 -i jasper-1.900.1-security_fixes-1.patch
./configure --prefix=/ffp --enable-shared --disable-static --mandir=/ffp/share/man
make
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "JasPer is a collection of software (i.e., a library and application programs) for the coding" >> ${SOURCEDIR}/install/DESCR
echo "and manipulation of images.  This software can handle image data in a variety of formats." >> ${SOURCEDIR}/install/DESCR
echo "One such format supported by JasPer is the JPEG-2000 format defined in ISO/IEC 15444-1." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: s:gcc-solibs s:libjpeg s:uClibc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/serviio" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/serviio
fi
if [ ! -d "/ffp/funpkg/additional/serviio" ]; then
    mkdir -p /ffp/funpkg/additional/serviio
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/serviio/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/serviio/
cd
rm -rf ${SOURCEDIR}