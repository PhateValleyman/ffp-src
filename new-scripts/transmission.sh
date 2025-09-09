#!/ffp/bin/bash

set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=transmission
VERSION="2.92"
SOURCEURL=https://github.com/transmission/transmission-releases/raw/master/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=http://www.transmissionbt.com/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
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
wget -nv ${SOURCEURL}
tar xf "${SOURCEURL##*/}"
cd ${PACKAGENAME}-${VERSION}
# Update third-party libs source codes-some of them are very old, buggy and vulnerable
# Adjust utp send and receive buffer sizes for zyxel NSA 3** series (default and max size are the same-112640 at least on NSA310)
# Transmission wants a lot more: echo 4194304 > /proc/sys/net/core/rmem_max; echo 1048576 > /proc/sys/net/core/wmem_max
sed -i '/^#define RECV_BUFFER_SIZE/c\#define RECV_BUFFER_SIZE (110 * 1024)'  libtransmission/tr-udp.c
sed -i '/^#define SEND_BUFFER_SIZE/c\#define SEND_BUFFER_SIZE (110 * 1024)'  libtransmission/tr-udp.c
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
# Supress warning messages-warning: cast increases required alignment of target type
sed -i "s|-Wcast-align||g" configure
./configure \
	--build="$GNU_BUILD" \
	--host="$GNU_HOST" \
	--prefix=/ffp \
	--enable-lightweight
cd third-party
wget -nv https://github.com/jech/dht/archive/dht-0.24.tar.gz
tar xf dht-0.24.tar.gz
rm dht-dht-0.24/Makefile
mv dht-dht-0.24/* dht/
wget -nv 'http://miniupnp.free.fr/files/libnatpmp-20150609.tar.gz'
tar xf libnatpmp-20150609.tar.gz
cp -a libnatpmp/Makefile libnatpmp/Makefile.old
mv libnatpmp-20150609/* libnatpmp
# libutp fails
#wget -nv https://github.com/bittorrent/libutp/archive/master.zip
#unzip -q master.zip
#mv libutp-master/* libutp
wget -nv 'http://miniupnp.free.fr/files/miniupnpc-2.0.20170509.tar.gz'
tar xf miniupnpc-2.0.20170509.tar.gz
cp -a miniupnp/Makefile miniupnp/Makefile.old
mv miniupnpc-2.0.20170509/* miniupnp
cd ${BUILDDIR}/${PACKAGENAME}-${VERSION}
# Compile external libs first
for ext_libs in dht libnatpmp miniupnp
do
	cd ${BUILDDIR}/${PACKAGENAME}-${VERSION}/third-party/"$ext_libs"
	make
done
cd ${BUILDDIR}/${PACKAGENAME}-${VERSION}
mv third-party/miniupnp/libminiupnpc.a third-party/miniupnp/libminiupnp.a
make
mv third-party/libnatpmp/Makefile.old third-party/libnatpmp/Makefile
mv third-party/miniupnp/Makefile.old third-party/miniupnp/Makefile
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Transmission is open source cross-platform BitTorrent client. It has the most features you can want
from a BitTorrent client: encryption, a web interface, peer exchange, magnet links, DHT, µTP, UPnP 
and NAT-PMP port forwarding, webseed support, watch directories, tracker editing, global and per-torrent
speed limits, and more.
License: MIT
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/${PACKAGENAME}.sh ${BUILDDIR}/ffp/start/
chmod 644 ${BUILDDIR}/ffp/start/${PACKAGENAME}.sh
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
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from list of dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$((ENDTIME-STARTTIME))
echo "End point:$(date -d @"${ENDTIME}" +%F\ %T)"
echo "Compile duration: $((DIFF / 3600 )) hours $((DIFF / 60 % 60)) minutes and $((DIFF % 60)) seconds"