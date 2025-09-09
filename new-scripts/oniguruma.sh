#!/ffp/bin/sh

set -e
#export TMPDIR="/mnt/HD_a2/tmp"
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
VERSION="5.9.4"
SOURCEURL=http://www.geocities.jp/kosako3/oniguruma/archive/onig-${VERSION}.tar.gz
HOMEURL=http://www.geocities.jp/kosako3/oniguruma/
SHORTNAME=onig
PACKAGENAME=oniguruma
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
tar xvzf ${SHORTNAME}-${VERSION}.tar.gz
cd ${SHORTNAME}-${VERSION}
#adapt executables to FFP prefix
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: uClibc uClic-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${SHORTNAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
cd ${SOURCEDIR}
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
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages
fi
if [ ! -d "/ffp/funpkg/additional" ]; then
    mkdir -p /ffp/funpkg/additional
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/
cd
rm -rf ${SOURCEDIR}