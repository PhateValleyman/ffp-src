#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=serviio
VERSION="1.8"
SOURCEURL=http://download.serviio.org/releases/${PACKAGENAME}-${VERSION}-linux.tar.gz
HOMEURL=http://serviio.org/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}"
PKGDIRBACKUP=/ffp/funpkg/additional/${PACKAGENAME}
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
mkdir -p ffp/opt/serviio
wget -nv ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.gz
tar xf ${PACKAGENAME}-${VERSION}.tar.gz --strip-components=1 -C ${BUILDDIR}/ffp/opt/serviio
#--exclude='bin'
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Serviio is a free media server. It allows you to stream your media files (music, video or images)
to renderer devices (e.g. a TV set, Bluray player, games console or mobile phone) on your connected
home network.
There is also a paid for Pro edition which further enhances the possibilities of sharing content
in your connected household.
Serviio works with many devices from your connected home (TV, Playstation 3, XBox 360, smart phones,
tablets, etc.). It supports profiles for particular devices so that it can be tuned to maximise the
device's potential and/or minimize lack of media format playback support (via transcoding).
Serviio is based on Java technology and therefore runs on most platforms, including Windows, Mac and
Linux (incl. embedded systems, e.g. NAS).
License:custom Serviio-view at http://serviio.org/licence
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:ffmpeg br2:fontconfig br2:freetype br2:fribidi br2:lame br2:libass br2:opus br2:rtmpdump
br2:shine br2:twolame br2:x264 br2:dcraw br2:jasper br2:lcms br2:libtiff br2:gcc-solibs br2:uClibc-solibs
Additionaly Java 8 runtime enviroment (jre)

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/${PACKAGENAME}.sh ${BUILDDIR}/ffp/start/
# Create postinstall script to remove old start-up script
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/${PACKAGENAME}.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh
pkg_install_date=\$(date "+%Y%m%d_%M%S")
if  [ -f /ffp/start/${PACKAGENAME}d.sh ]; then
    mv /ffp/start/${PACKAGENAME}d.sh /ffp/start/${PACKAGENAME}d.sh.old.\$pkg_install_date
    chmod 644 /ffp/start/${PACKAGENAME}d.sh.old.\$pkg_install_date
fi
if  [ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
   if  [ -f /ffp/start/${PACKAGENAME}.sh ]; then
       mv /ffp/start/${PACKAGENAME}.sh /ffp/start/${PACKAGENAME}.sh.old.\$pkg_install_date
       chmod 644 /ffp/start/${PACKAGENAME}.sh.old.\$pkg_install_date
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
# Add dependencies
echo "dcraw ffmpeg lame libass rtmpdump x264 oracle-java8-installer" > ${BUILDDIR}/install/DEPENDS
cat > ${BUILDDIR}/install/slack-required << EOF
dcraw
ffmpeg
lame
libass
rtmpdump
x264
oracle-java8-installer
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"