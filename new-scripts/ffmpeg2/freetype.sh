#!/ffp/bin/sh

set -e
#export TMPDIR=/mnt/HD_a2/tmp
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
VERSION=2.5.0.1
SOURCEURL=http://download.savannah.gnu.org/releases/freetype/freetype-${VERSION}.tar.gz
HOMEURL=http://www.freetype.org/
PACKAGENAME=freetype
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
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
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
# Enable GX/AAT and OpenType table validation and Subpixel Rendering and Subpixel Hinting http://www.linuxfromscratch.org/blfs/view/svn/general/freetype2.html
sed -i  -e "/AUX.*.gxvalid/s@^# @@" \
        -e "/AUX.*.otvalid/s@^# @@" \
        modules.cfg                         &&
sed -ri -e 's:.*(#.*SUBPIXEL.*) .*:\1:' \
        include/freetype/config/ftoption.h  &&
./configure --prefix=/ffp --enable-shared --enable-static --without-png
make
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo -e "FreeType2 is a software font engine that is designed to be small, efficient,highly customizable \nand portable while capable of producing high-quality output (glyph images). \nRequires libraries from:zlib, bzip2" >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
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