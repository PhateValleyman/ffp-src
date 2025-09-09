#!/ffp/bin/bash

# When extracting picture (thumbnail) from video warning appears:
# [swscaler @ 0x43e40] No accelerated colorspace conversion found from yuv420p to rgb24.
# It is expected on arm platform.
# It's related to their being no architecture specific version of the colorspace conversion for the CPU you
# are targeting. The warning is simply that no one has written an optimized version of the colorspace conversion
# in libswscale for ARM. I can only see PPC and x86 asm versions, i.e. it's nothing to worry about.
# https://ffmpeg.org/pipermail/libav-user/2015-February/007910.html

set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=ffmpeg
GITVERSION=3.3
GITBRANCH=release/${GITVERSION}
GITURL=git://source.ffmpeg.org/ffmpeg.git
HOMEURL=http://www.ffmpeg.org
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/ffmpeg3"
PKGDIRBACKUP="/ffp/funpkg/additional/ffmpeg3"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @"${STARTTIME}" +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
# Get source code from specific release git repo branch
git clone -q -b ${GITBRANCH} ${GITURL} ${PACKAGENAME}
cd ${PACKAGENAME}
VERSION="$(cat RELEASE)_git$(git rev-parse --short HEAD)"
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

#https://trac.ffmpeg.org/wiki/Encode/AAC
#
#https://ffmpeg.org/general.html
# 	--enable-pthreads \ unnecessary (by default yes-autodetected)
#	--enable-libfdk-aac \ (not compatible with GPL)
#	--enable-openssl \ (not compatible with GPL, using gnutls instead)
#	--enable-nonfree \ (used if included external libs are not compatible with GPL: Fraunhofer AAC-libfdk-aac. Result of nonfree is not distributable ffmpeg!)
#   --enable-version3 \ (used if some of included external libs needs GPLv3 compatibility: OpenCORE, VisualOn)
#	--disable-xlib \ (x11 lib? For some reason, ffmpeg since version 3.* wants to use xlib, even it is not present. Seriously, where ffmpeg autotests finds it?)
#	--enable-pic \ (for shared libs?, but why ffmpeg docs recommends it for static ones? ffmpeg becames a bit slower 2% if pic is used)
# http://davidad.github.io/blog/2014/02/19/relocatable-vs-position-independent-code-or/
#
#Quote from https://ffmpeg.org/ffmpeg-filters.html#subtitles-1 (drawtext ffmpeg filter):
# Draw a text string or text from a specified file on top of a video, using the libfreetype library.
# To enable compilation of this filter, you need to configure FFmpeg with --enable-libfreetype.
# To enable default font fall back and the font option you need to configure FFmpeg with --enable-libfontconfig.
# To enable the text_shaping option, you need to configure FFmpeg with --enable-libfribidi. 
#If libfreetype is enabled, then ffmpeg build fails at linking stage with following errors:
# libavfilter/libavfilter.so: undefined reference to `fetestexcept'
# libavfilter/libavfilter.so: undefined reference to `feclearexcept'
#Problem is in libavfilter/vf_drawtext.c used functions fetestexcept and feclearexcept, which aren't available in uClibc, even fenv.h is present:
# https://trac.ffmpeg.org/ticket/4796
# http://lists.busybox.net/pipermail/buildroot/2015-January/118173.html
# https://stackoverflow.com/questions/33191530/undefined-reference-to-functions-in-fenv-h
# So, freetype can not be used with uClibc for ffmpeg build. That makes no sense of further using fontconfig and fridibi for ffmpeg compilation as well. 
# In the other words, fontconfig is useful, fribidi is improvement for drawtext ffmpeg filter, but only if freetype is used, since it is requirement for drawtext.
# Nice explanation of possible config options - https://wiki.gentoo.org/wiki/FFmpeg
#
# build1: specialized for armv5te CPU (commented options below)
# build2: more generic-supports CPU since armv4t, NEON and VFP enabled (a bit slower 3-4% on armv5, but should be faster on armv6 and armv7)
#
#	--cpu=armv5te \
#	--disable-runtime-cpudetect \
#	--disable-armv6 \
#	--disable-armv6t2 \
#	--disable-vfp \
#	--disable-neon \

./configure \
	--prefix=/ffp \
	--disable-debug \
	--disable-stripping \
	--disable-ffplay \
	--disable-ffserver \
	--disable-doc \
	--disable-htmlpages \
	--disable-podpages \
	--disable-txtpages \
	--disable-xlib \
	--disable-static \
	--enable-shared \
	--enable-gpl \
	--enable-avresample \
	--enable-gnutls \
	--enable-libass \
	--enable-libmp3lame \
	--enable-libopus \
	--enable-librtmp \
	--enable-libshine \
	--enable-libtheora \
	--enable-libtwolame \
	--enable-libv4l2 \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-libwebp \
	--enable-libx264 \
	--enable-libx265 \
	--extra-cflags=-Wno-deprecated-declarations \
	--extra-version=compiled_by_barmalej2_for_ffp0.7arm
make
# make examples (Who needs them?)
# Compile additionally qt-faststart utility, which can modify QuickTime formatted movies (.mov or .mp4),
# so that the header information is located at the beginning of the file instead of the end.
# This allows the movie file to begin playing before the entire file has been downloaded. 
#gcc tools/qt-faststart.c -o tools/qt-faststart
make tools/qt-faststart
make DESTDIR=${BUILDDIR} install install-man
install -v -m755 tools/qt-faststart ${BUILDDIR}/ffp/bin
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

FFmpeg is a complete, cross-platform solution to record, convert and stream audio and video.
It is the leading multimedia framework, able to decode, encode, transcode, mux, demux, stream,
filter and play pretty much anything that humans and machines have created.
License: GNU GPLv2 or later
Version: ${VERSION}, compiled by barmalej2 for ffp0.7arm
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Install licence
mkdir -p "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}"
install -Dm644 COPYING.GPLv2 "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}/COPYING.GPLv2"
install -Dm644 LICENSE.md "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}/LICENSE"
cd ${BUILDDIR}
rm -rf ${BUILDDIR:?}/${PACKAGENAME}
# Remove unused docs
if [ -d ${BUILDDIR}/ffp/share/doc ]
then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
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
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} "${VERSION}" 2
cp -a "${PKGDIR}/${PACKAGENAME}-${VERSION}"-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$((ENDTIME-STARTTIME))
echo "End point:$(date -d @"${ENDTIME}" +%F\ %T)"
echo "Build duration: $((DIFF / 3600 )) hours $((DIFF / 60 % 60)) minutes and $((DIFF % 60)) seconds"