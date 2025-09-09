#!/ffp/bin/bash

# Older gcc without enabled atomics (< 4.80) is required to build tvheadend. Otherwise we will get error:
# A newer kernel is required to run this binary. (__kernel_cmpxchg64 helper)
# https://gcc.gnu.org/wiki/Atomic
# http://uhurumkate.blogspot.com/2014/07/a-newer-kernel-is-required-to-run-this.html
# ARM supports 8 byte atomics with cmpxchg64 kernel helper with gcc-4.8 + Linux 3.1 (or Linux 2.6.30 w/ armv6k+)
# Workaround of problem for gcc>4.92 is below
set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
LDFLAGS="-lubacktrace"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=tvheadend
VERSION="4.2.2"
SOURCEURL=https://github.com/tvheadend/tvheadend/archive/v${VERSION}.tar.gz
HOMEURL=https://tvheadend.org
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR LDFLAGS
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
wget -nv ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.gz
tar xf ${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}-${VERSION}
# We don't have realpath on FFP
sed -i 's|$(basename $(realpath $(dirname "$0")/..)|$(basename $(dirname $(dirname $(readlink -f "$0")))|' support/version
# Correct path to tar
sed -i 's|/bin/tar|/ffp/bin/tar|' src/config.c
# For gcc 4.92 and above-disable atomic ops to compile correctly with newer compilers
sed -i 's|uint64_t|uint65_t|' configure
# Change default dvr directory to /mnt/HD_a2/video instead of /ffp/etc/tvheadend (might full fill ffp stick)
sed -i 's|homedir = getenv("HOME");|homedir = "/mnt/HD_a2/video";|' src/dvr/dvr_config.c
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
# Add --nowerror config option, otherwise compilation will fail, because of unused variable:
# src/input/mpegts/linuxdvb/linuxdvb_frontend.c:1832:12: error: unused variable 'j' [-Werror=unused-variable] 
./configure \
	--prefix=/ffp \
	--disable-avahi \
	--release \
	--disable-ffmpeg_static \
	--disable-libx264_static \
	--disable-libx265_static \
	--disable-libvorbis_static \
	--disable-libvpx_static \
	--disable-libtheora_static \
	--disable-libfdkaac \
	--disable-libfdkaac_static \
	--nowerror
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Tvheadend is a TV streaming server for Linux supporting DVB, ATSC, IPTV, and Analog video (V4L)
as input sources. Can be used as a backend to Showtime, XBMC and various other clients.
License: GPLv3
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unnecessary stuff
if	[ -d ${BUILDDIR}/ffp/share/doc ]; then
	rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if	[ -d ${BUILDDIR}/ffp/lib ]; then
	find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
	find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Adapt scripts to FFP prefix before packaging
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
# Add bzip2 tar v4l-dvb v4l-utils eudev kmod dvb-apps to list of deps
sed -i "s|\<dvb-apps\>|bzip2 tar v4l-dvb v4l-utils eudev kmod dvb-apps|" ${BUILDDIR}/install/DEPENDS
cat >> ${BUILDDIR}/install/slack-required <<- EOF
bzip2
tar
v4l-dvb
v4l-utils
eudev
kmod
EOF
# Copy prepared configs and startup files
mkdir -p ${BUILDDIR}/ffp/etc/${PACKAGENAME}
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/${PACKAGENAME}.sh ${BUILDDIR}/ffp/start
cp -a ${SCRIPTDIR}/${PACKAGENAME}.conf ${BUILDDIR}/ffp/etc/${PACKAGENAME}
# Create postinstall script to remove old start-up script
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/${PACKAGENAME}.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

DATE=\$(date "+%Y%m%d_%H%M%S")

if  [ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
   if  [ -f /ffp/start/${PACKAGENAME}.sh ]; then
       mv /ffp/start/${PACKAGENAME}.sh /ffp/start/${PACKAGENAME}.sh.old\${DATE}
       chmod 644 /ffp/start/${PACKAGENAME}.sh.old\${DATE}
       mv /ffp/start/${PACKAGENAME}.sh.new /ffp/start/${PACKAGENAME}.sh
   else
       mv /ffp/start/${PACKAGENAME}.sh.new /ffp/start/${PACKAGENAME}.sh
   fi
fi
if  [ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') != $CHECKSUM ]; then
    rm /ffp/start/${PACKAGENAME}.sh.new
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"