#!/ffp/bin/sh

set -e
export FFP_ARCH="arm"
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
PACKAGENAME=udpxy
SOURCEURL=https://github.com/pcherenkov/${PACKAGENAME}.git
HOMEURL=http://www.udpxy.com/
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
git clone ${SOURCEURL}
cd ${PACKAGENAME}/chipmunk
VERSION=$(cat VERSION | cut -f2 -d'"').$(cat BUILD).$(cat PATCH)_git$(date "+%Y%m%d")
# Adapt pidfile path
sed -i "s|/var/run|/ffp/var/run|" osdef.h
sed -i "s|/var/tmp|/ffp/var/tmp|" osdef.h
#adapt executables to FFP prefix
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
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
make
make install DESTDIR=${SOURCEDIR} PREFIX=/ffp MANPAGE_DIR=${SOURCEDIR}/ffp/share/man/man1
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "udpxy is a UDP-to-HTTP multicast traffic relay daemon: it forwards UDP traffic from" >> ${SOURCEDIR}/install/DESCR
echo "a given multicast subscription to the requesting HTTP client. udpxy is free and open" >> ${SOURCEDIR}/install/DESCR
echo "source: it is licensed under GNU GPLv3." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires packages from:" >> ${SOURCEDIR}/install/DESCR
echo "uClibc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
# Copy  start-up script
mkdir -p ${SOURCEDIR}/ffp/start
cp /ffp/start/${PACKAGENAME}.sh ${SOURCEDIR}/ffp/start/
# Create postinstall script to remove old start-up script
CHECKSUM=`md5sum ${SOURCEDIR}/ffp/start/udpxy.sh|awk '{print $1}'`
cat > ${SOURCEDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
if [ -f /ffp/start/udpxy.sh.new ] && [ `md5sum /ffp/start/udpxy.sh.new|awk '{print $1}'` = CHECKSUM ]; then
   mv /ffp/start/udpxy.sh.new /ffp/start/udpxy.sh
fi
if [ -f /ffp/start/udpxy.sh.new ] && [ `md5sum /ffp/start/udpxy.sh.new|awk '{print $1}'` != CHECKSUM ]; then
   rm /ffp/start/udpxy.sh.new
fi
EOF
chmod 755 ${SOURCEDIR}/install/doinst.sh
# Correct CHECKSUM and in doinst.sh
sed -i "s|CHECKSUM|$CHECKSUM|g" ${SOURCEDIR}/install/doinst.sh
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
#adapt executables to FFP prefix again
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
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
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds"