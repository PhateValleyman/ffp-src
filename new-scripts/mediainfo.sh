#!/ffp/bin/sh

#
######BIG FAT warning uninstall current mediainfo package, before building new version with this script
######Build order:libmms first, then libzen, libmediainfo and the last mediainfo cli.
#
set -e
CFLAGS="-march=armv5te"
CXXFLAGS="${CFLAGS}"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=mediainfo
VERSION=0.7.79
DEP1=libzen
DEP1_VERSION=0.4.32
DEP2=libmms
DEP2_VERSION=0.6.4
SOURCEURL1=http://mediaarea.net/download/source/${PACKAGENAME}/${VERSION}/${PACKAGENAME}_${VERSION}.tar.bz2
SOURCEURL2=http://mediaarea.net/download/source/lib${PACKAGENAME}/${VERSION}/lib${PACKAGENAME}_${VERSION}.tar.bz2
SOURCEURL3=http://mediaarea.net/download/source/libzen/${DEP1_VERSION}/${DEP1}_${DEP1_VERSION}.tar.bz2
SOURCEURL4=http://download.sourceforge.net/${DEP2}/${DEP2}-${DEP2_VERSION}.tar.gz
HOMEURL=https://mediaarea.net/en/MediaInfo
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR CFLAGS CXXFLAGS
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
for SRCURL in ${SOURCEURL1} ${SOURCEURL2} ${SOURCEURL3} ${SOURCEURL4}; do
	wget -nv ${SRCURL}
done
for SRCFILE in ${PACKAGENAME}_${VERSION}.tar.bz2 lib${PACKAGENAME}_${VERSION}.tar.bz2 ${DEP1}_${DEP1_VERSION}.tar.bz2 ${DEP2}-${DEP2_VERSION}.tar.gz; do
	tar xf ${SRCFILE}
	rm ${SRCFILE}
done
# Adapt scripts to FFP prefix
# Correct configure.ac for libzen libmediainfo and mediainfo
sed -i 's|^AC_PROG_LIBTOOL|LT_INIT|' */Project/GNU/*/configure.ac
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
# libmms first
cd ${DEP2}-${DEP2_VERSION}
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--enable-shared \
	--disable-static
make
echo "Installing libmms:"
make install
make install DESTDIR=${BUILDDIR}
# libzen second
cd ${BUILDDIR}
rm -rf ${DEP2}-${DEP2_VERSION}
cd ZenLib/Project/GNU/Library
autoreconf -fi
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--enable-shared \
	--disable-static
make clean
make
make install DESTDIR=${BUILDDIR}
[ -f ${BUILDDIR}/ffp/bin/libzen-config ] && rm -rf ${BUILDDIR}/ffp/bin/libzen-config
install -dm 755 ${BUILDDIR}/ffp/include/ZenLib
install -m 644 ${BUILDDIR}/ZenLib/Source/ZenLib/*.h ${BUILDDIR}/ffp/include/ZenLib
for i in HTTP_Client Format/Html Format/Http; do
	install -dm0755 ${BUILDDIR}/ffp/include/ZenLib/$i
	install -m0644 ${BUILDDIR}/ZenLib/Source/ZenLib/$i/*.h ${BUILDDIR}/ffp/include/ZenLib/$i
done
# Install libzen to ffp
echo "Installing libzen:"
cp -avrf ${BUILDDIR}/ffp/* /ffp
# libmediainfo is build third
cd ${BUILDDIR}
rm -rf ZenLib 
cd MediaInfoLib/Project/GNU/Library
autoreconf -fi
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--enable-shared \
	--disable-static \
	--with-libcurl \
	--with-libmms
make clean
cd ${BUILDDIR}/MediaInfoLib
wget -nv 'https://projects.archlinux.org/svntogit/community.git/plain/trunk/libmediainfo-0.7.50-libmms.patch?h=packages/libmediainfo' -O lib${PACKAGENAME}.patch
patch -p1 < lib${PACKAGENAME}.patch
cd ${BUILDDIR}/MediaInfoLib/Project/GNU/Library
make
make install DESTDIR=${BUILDDIR}
for i in MediaInfo MediaInfoDLL; do
	install -dm 755 ${BUILDDIR}/ffp/include/$i
	install -m 644 ${BUILDDIR}/MediaInfoLib/Source/$i/*.h ${BUILDDIR}/ffp/include/$i
done
install -dm 755 ${BUILDDIR}/ffp/lib/pkgconfig
install -m 644 ${BUILDDIR}/MediaInfoLib/Project/GNU/Library/libmediainfo.pc ${BUILDDIR}/ffp/lib/pkgconfig
# Install libmediainfo to ffp
echo "Installing libmediainfo:"
cp -avrf ${BUILDDIR}/ffp/* /ffp
# Build mediainfo cli last
cd ${BUILDDIR}
rm -rf MediaInfoLib 
cd MediaInfo/Project/GNU/CLI
autoreconf -fi
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp
make clean
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
MediaInfo is a convenient unified display of the most relevant technical and tag data for video
and audio files. This package also contains libmms, libzen and libmediainfo libraries.
License: BSD-style
Version:${VERSION}
Homepage:${HOMEURL}
Depends on these packages:
br2:curl br2:gcc-solibs br2:gettext br2:glib br2:libiconv br2:openssl br2:pcre br2:uClibc-solibs
uli:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf MediaInfo
# Remove unnecessary stuff
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
if [ -d ${BUILDDIR}/ffp/install ]; then
   mv ${BUILDDIR}/ffp/install/* ${BUILDDIR}/install
   rm -rf ${BUILDDIR}/ffp/install
fi
# Remove duplicate gcc and uclibc and in some cases package itsef dependencies requirements
for pkgname in gcc uClibc ${PACKAGENAME} lib${PACKAGENAME} glib2; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"