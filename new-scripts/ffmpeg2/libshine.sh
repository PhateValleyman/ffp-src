#!/ffp/bin/sh

set -e
#export TMPDIR=/mnt/HD_a2/tmp
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
VERSION=3.0.0
SOURCEURL=https://github.com/savonet/shine/archive/${VERSION}.tar.gz
HOMEURL=https://github.com/savonet/shine
PACKAGENAME=shine
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.gz
tar xvzf ${PACKAGENAME}-${VERSION}.tar.gz
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
./bootstrap
#adapt executables to FFP prefix again after bootstraping
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
./configure --enable-shared --disable-static --prefix=/ffp
make
#-----don't worry about the repeated message #warning NO MULT FILE FOR ARCHITECTURE - USING GENERIC MATH
#-----the include for mult_sarm_gcc.h (optimized ARM maths in assembler) is commented out in src/lib/types.h
#-----the comment mentions that fixing this is on the to-do list, so it can't be helped
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
cat ${SOURCEDIR}/ffp/lib/pkgconfig/${PACKAGENAME}.pc | grep -e "Name" -e "Description" -e "Version" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
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