#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
SOURCEURL=http://tsdemuxer.googlecode.com/svn/trunk/xupnpd
HOMEURL=http://xupnpd.org
PACKAGENAME=xupnpd
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
svn co -q ${SOURCEURL}
cd ${PACKAGENAME}/src
# Adapt source to ffp
sed -i "s|usr|ffp|g" main.cpp
# Make changes to config file
sed -i "/^cfg.ssdp_loop=1/c\cfg.ssdp_loop=0" xupnpd.lua
sed -i "/^cfg.daemon=false/c\cfg.daemon=true" xupnpd.lua
sed -i "/^cfg.embedded=false/c\cfg.embedded=true" xupnpd.lua
sed -i "/^cfg.sort_files=false/c\cfg.sort_files=true" xupnpd.lua
# 2 variantas Vis dar klausimas ar reikia? sed -i "/^cfg.default_mime_type='mpeg'/c\cfg.default_mime_type='mpeg_ts'" xupnpd.lua
sed -i "/^cfg.feeds_update_interval=/c\cfg.feeds_update_interval=3600" xupnpd.lua
sed -i "s@cfg.pid_file='/var/run/'@cfg.pid_file='/ffp/var/run/'@" xupnpd.lua
sed -i "/^--cfg.feeds_path=/c\cfg.feeds_path='/tmp/xupnpd-feeds/'" xupnpd.lua
# 2 variantas sed -i "/^--cfg.feeds_path=/c\cfg.feeds_path='/tmp/xupnpd/feeds/'" xupnpd.lua
# 2 variantas sed -i "s|xupnpd-cache|xupnpd/cache|g" xupnpd_http.lua
# 2 variantas sed -i "s|cfg.sec_extras=false|cfg.sec_extras=true|g" xupnpd_main.lua profiles/skel/skel.lua 
VERSION=$(grep 'version' ${BUILDDIR}/${PACKAGENAME}/src/xupnpd.lua|awk -F "'" '{print $2}').$(svn info|grep Revision|awk -F ": " '{print $2}')_svn$(date "+%Y%m%d")
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
echo "" >> Makefile
echo "ffp:" >> Makefile
echo '	$(MAKE) embedded TARGET=ffp SDK=/ffp/bin UTILS=/ffp/libexec/gcc/arm-ffp-linux-uclibcgnueabi/4.9.2' >> Makefile
make clean
make ffp
mkdir -p ${BUILDDIR}/install
echo "" >> ${BUILDDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${BUILDDIR}/install/DESCR
echo "This program is a light DLNA Media Server which provides ContentDirectory:1 service for sharing IPTV" >> ${BUILDDIR}/install/DESCR
echo "streams over local area network. You can watch HDTV broadcasts (multicast or unicast) and listen" >> ${BUILDDIR}/install/DESCR
echo "Internet Radio without transcoding and PC." >> ${BUILDDIR}/install/DESCR
echo "Version:${VERSION}" >> ${BUILDDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${BUILDDIR}/install/DESCR
echo "" >> ${BUILDDIR}/install/DESCR
echo "Requires packages:" >> ${BUILDDIR}/install/DESCR
echo "uClibc-solibs" >> ${BUILDDIR}/install/DESCR
echo "" >> ${BUILDDIR}/install/DESCR
echo "ATTENTION!!!:Set static IP address for NAS is prerequisite!" >> ${BUILDDIR}/install/DESCR
echo "" >> ${BUILDDIR}/install/DESCR
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
mkdir -p ${BUILDDIR}/ffp/bin ${BUILDDIR}/ffp/share/xupnpd/config ${BUILDDIR}/ffp/share/xupnpd/localmedia ${BUILDDIR}/ffp/share/xupnpd/private ${BUILDDIR}/ffp/start
cp /ffp/start/xupnpd.sh ${BUILDDIR}/ffp/start/
cp ${BUILDDIR}/${PACKAGENAME}/src/xupnpd-ffp ${BUILDDIR}/ffp/bin/xupnpd
cp  ${BUILDDIR}/${PACKAGENAME}/src/*.lua ${BUILDDIR}/ffp/share/xupnpd/
cp -r ${BUILDDIR}/${PACKAGENAME}/src/playlists/ ${BUILDDIR}/ffp/share/xupnpd/
cp -r ${BUILDDIR}/${PACKAGENAME}/src/plugins/ ${BUILDDIR}/ffp/share/xupnpd/
cp -r ${BUILDDIR}/${PACKAGENAME}/src/profiles/ ${BUILDDIR}/ffp/share/xupnpd/
cp -r ${BUILDDIR}/${PACKAGENAME}/src/ui/ ${BUILDDIR}/ffp/share/xupnpd/
cp -r ${BUILDDIR}/${PACKAGENAME}/src/www/ ${BUILDDIR}/ffp/share/xupnpd/
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}
# Create postinstall script to remove old start-up script
CHECKSUM=`md5sum ${BUILDDIR}/ffp/start/xupnpd.sh|awk '{print $1}'`
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
if [ -f /ffp/start/xupnpd.sh.new ] && [ `md5sum /ffp/start/xupnpd.sh.new|awk '{print $1}'` = CHECKSUM ]; then
   mv /ffp/start/xupnpd.sh.new /ffp/start/xupnpd.sh
fi
if [ -f /ffp/start/xupnpd.sh.new ] && [ `md5sum /ffp/start/xupnpd.sh.new|awk '{print $1}'` != CHECKSUM ]; then
   rm /ffp/start/xupnpd.sh.new
fi
if [ -f /ffp/share/xupnpd/xupnpd.lua ]; then
   IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
   NIC=`ifconfig | grep Ethernet | head -n1 | cut -d ' ' -f1`
   sed -i "/^cfg.ssdp_interface=/c\cfg.ssdp_interface='${NIC}'" /ffp/share/xupnpd/xupnpd.lua
   sed -i "s@192.168.1.1@${IP}@g" /ffp/share/xupnpd/xupnpd.lua
   sed -i "/^cfg.mcast_interface=/c\cfg.mcast_interface='${NIC}'" /ffp/share/xupnpd/xupnpd.lua
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Correct CHECKSUM and in doinst.sh
sed -i "s|CHECKSUM|$CHECKSUM|g" ${BUILDDIR}/install/doinst.sh
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/
fi
if [ ! -d "/ffp/funpkg/additional/" ]; then
    mkdir -p /ffp/funpkg/additional/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"