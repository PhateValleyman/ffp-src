#!/ffp/bin/sh

# When extracting picture (thumbnail) from video warning appears:
# [swscaler @ 0x43e40] No accelerated colorspace conversion found from yuv420p to rgb24.
# It is expected on arm platform.
# It's related to their being no architecture specific version of the colorspace conversion for the CPU you
# are targeting. The warning is simply that no one has written an optimized version of the colorspace conversion
# in libswscale for ARM. I can only see PPC and x86 asm versions, i.e. it's nothing to worry about.
# https://ffmpeg.org/pipermail/libav-user/2015-February/007910.html
#ffmpeg is missing decoder h264_qsv
#ffmpeg is missing decoder mpeg2_qsv
#ffmpeg is missing decoder vc1_qsv
#ffmpeg is missing encoder libx265
#ffmpeg is missing encoder libvpx
#ffmpeg is missing encoder libvorbis

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
# Suppress a lot annoying warnings about deprecated functions
# CFLAGS="$CFLAGS -Wno-deprecated-declarations"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=ffmpeg
GITVERSION=2.1
GITBRANCH=release/${GITVERSION}
GITURL=git://source.ffmpeg.org/ffmpeg.git
HOMEURL=http://www.ffmpeg.org
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/ffmpeg2"
PKGDIRBACKUP="/ffp/funpkg/additional/ffmpeg2"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
# Get source code from specific release git repo branch
git clone -q -b ${GITBRANCH} ${GITURL} ${PACKAGENAME}
cd ${PACKAGENAME}
VERSION=$(cat VERSION|xargs)_git$(date "+%Y%m%d")
#### ARM-specific fixed point maths modification for mpeg audio encoder
sed -i "s/^#define USE_FLOATS//" libavcodec/mpegaudioenc.c
# Adapt scripts to FFP prefix
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
# 	--enable-pthreads \ unnecessary (autodetected)
#	--enable-pic \
#	--enable-libfdk-aac \ not compatible with GPL
#	--enable-nonfree \
# 	--enable-openssl \ not compatible with GPL
#   to do-add x265, libvpx, libvorbis with 2.7 release
#   https://trac.ffmpeg.org/wiki/Encode/AAC
./configure \
	--prefix=/ffp \
	--enable-shared \
	--disable-static \
	--disable-armv6 \
	--disable-armv6t2 \
	--disable-vfp \
	--disable-neon \
	--disable-debug \
	--disable-stripping \
	--disable-ffplay \
	--disable-ffserver \
	--disable-indev=alsa \
	--disable-outdev=alsa \
	--enable-avresample \
	--enable-gpl \
	--enable-version3 \
	--enable-libx264 \
	--enable-libshine \
	--enable-libmp3lame \
	--enable-libtwolame \
	--enable-libopus \
	--enable-librtmp \
	--enable-libass \
	--enable-fontconfig \
	--enable-libfreetype \
	--disable-doc \
	--disable-htmlpages \
	--disable-podpages \
	--disable-txtpages \
	--extra-cflags=-Wno-deprecated-declarations \
	--extra-version=compiled_by_barmalej2_for_ffp0.7arm
make
# make examples (Who needs them?)
# Compile additionally qt-faststart utility, which can modify QuickTime formatted movies (.mov or .mp4),
# so that the header information is located at the beginning of the file instead of the end.
# This allows the movie file to begin playing before the entire file has been downloaded. 
gcc tools/qt-faststart.c -o tools/qt-faststart
make DESTDIR=${BUILDDIR} install install-man
install -v -m755 tools/qt-faststart ${BUILDDIR}/ffp/bin
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
FFmpeg is a complete, cross-platform solution to record, convert and stream audio and video.
It is the leading multimedia framework, able to decode, encode, transcode, mux, demux, stream,
filter and play pretty much anything that humans and machines have created.
License:GNU GPLv3 or later
Version:${VERSION}, compiled by barmalej2 for ffp0.7arm
Homepage:${HOMEURL}
Depends on these packages:
expat fontconfig freetype fribidi gcc-solibs gettext lame libiconv libass
openssl opus rtmpdump shine twolame x264 uClibc-solibs zlib bzip2

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}
# Remove unnecessary stuff
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Adapt scripts to FFP prefix again before making package
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
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"