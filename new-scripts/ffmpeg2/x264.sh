#!/ffp/bin/sh

set -e
#export TMPDIR=/mnt/HD_a2/tmp
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
SOURCEURL=git://git.videolan.org/x264.git
GITBRANCH=remotes/origin/stable
HOMEURL=http://www.videolan.org/developers/x264.html
PACKAGENAME=x264
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
git clone ${SOURCEURL}
cd ${PACKAGENAME}
git checkout -b ${PACKAGENAME} ${GITBRANCH}
git pull
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
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
./configure --prefix=/ffp --disable-asm --enable-shared
make
make install DESTDIR=${SOURCEDIR}
VERSION=`cat ${SOURCEDIR}/ffp/lib/pkgconfig/${PACKAGENAME}.pc|grep Version|awk -F' ' '{print $2}'|cut -f1,2 -d'.'`_git`date "+%Y%m%d"`
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
cat ${SOURCEDIR}/ffp/lib/pkgconfig/${PACKAGENAME}.pc | grep -e "Name" -e "Description" -e "Version" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: ffmpeg gcc-solibs uClibc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/ffmpeg2" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/ffmpeg2
fi
if [ ! -d "/ffp/funpkg/additional/ffmpeg2" ]; then
    mkdir -p /ffp/funpkg/additional/ffmpeg2
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/ffmpeg2/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/ffmpeg2/
cd
rm -rf ${SOURCEDIR}