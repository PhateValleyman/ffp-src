#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
SOURCEURL=http://www.cybercom.net/~dcoffin/dcraw/archive/dcraw-9.20.tar.gz
HOMEURL=http://www.cybercom.net/~dcoffin/dcraw/
PACKAGENAME=dcraw
VERSION=`echo ${SOURCEURL}|awk -F'-' '{print $2}'|cut -f1,2 -d'.'`
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
tar xvzf ${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}
sed -i 's/^#!.*$/#!\/ffp\/bin\/sh/g' install
sed -i "s@`grep ^prefix= install|xargs`@prefix=${SOURCEDIR}/ffp@" install
sed -i 's|gcc -O4 -march=native|gcc -O3 -march=armv5te|' install
sed -i 's|DLOCALEDIR|lintl -DLOCALEDIR|' install
sed -i 's|"$prefix/share/locale/|"/ffp/share/locale/|' install
sed -i '\,man/$lang,d' install
mkdir -p ${SOURCEDIR}/ffp/bin
chmod 755 install
./install
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "dcraw is a tool for decoding raw photos, displaying metadata and extracting thumbnails." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: s:gcc-solibs br2:jasper s:libjpeg br2:lcms br2:gettext br2:libiconv s:uClibc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}*
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