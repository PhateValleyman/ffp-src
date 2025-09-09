#!/ffp/bin/sh

set -e
export PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=rtmpdump
LIBNAME=librtmp
SOURCEURL=git://git.ffmpeg.org/rtmpdump
HOMEURL=http://rtmpdump.mplayerhq.hu
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
git clone ${SOURCEURL}
cd ${PACKAGENAME}
VERSION="$(grep "VERSION=v" Makefile | cut -f2 -d'v')_git$(date "+%Y%m%d")"
# Adapt scripts to FFP prefix
sed -i 's|OPT=-O2|OPT=-O3|g' ${BUILDDIR}/${PACKAGENAME}/Makefile
sed -i 's|usr/local|ffp|g' ${BUILDDIR}/${PACKAGENAME}/Makefile
sed -i 's|mandir=$(prefix)/man|mandir=$(prefix)/share/man|g' ${BUILDDIR}/${PACKAGENAME}/Makefile
sed -i 's|OPT=-O2|OPT=-O3|g' ${BUILDDIR}/${PACKAGENAME}/${LIBNAME}/Makefile
sed -i 's|usr/local|ffp|g' ${BUILDDIR}/${PACKAGENAME}/${LIBNAME}/Makefile
sed -i 's|mandir=$(prefix)/man|mandir=$(prefix)/share/man|g' ${BUILDDIR}/${PACKAGENAME}/${LIBNAME}/Makefile
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
make SYS=posix OPT="$CFLAGS" XLDFLAGS="$LDFLAGS" prefix=/ffp
make prefix=/ffp sbindir=/ffp/bin DESTDIR=${BUILDDIR} install
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
rtmpdump is a toolkit for RTMP streams. All forms of RTMP are supported including
rtmp://, rtmpt://, rtmpe://, rtmpte://, and rtmps://
License:GPL2, LGPL2.1
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:gcc-solibs br2:uClibc-solibs s:openssl s:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}*
# Remove unused docs
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
#Create symlinks for compatability with older version
ln -s librtmp.so.1 ${BUILDDIR}/ffp/lib/librtmp.so.0
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/ffmpeg2/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/ffmpeg2/
fi
if [ ! -d "/ffp/funpkg/additional/ffmpeg2/" ]; then
    mkdir -p /ffp/funpkg/additional/ffmpeg2/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/ffmpeg2/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/ffmpeg2/
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"