#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=rsync
VERSION="3.1.2"
SOURCEURL=http://rsync.samba.org/ftp/rsync/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=http://rsync.samba.org
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
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
wget -nv ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}-${VERSION}
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
./configure \
	--prefix=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--disable-debug \
	--disable-locale \
	--with-rsyncd-conf=/ffp/etc/rsyncd.conf \
	--with-nobody-group=nobody
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
The rsync package contains the rsync utility. This is useful for synchronizing large file archives
over a network. 
License:GPL v3
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
libiconv uClibc-solibs | uClibc

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Adapt stunnel config to /ffp
mkdir -p ${BUILDDIR}/ffp/etc/rsync-ssl/certs
sed -i "s|[[:space:]]/var| /ffp/var|g" stunnel-rsyncd.conf
sed -i "s|[[:space:]]/etc| /ffp/etc|g" stunnel-rsyncd.conf
sed -i "/^CAfile/c\CAfile = /ffp/etc/ssl/cert.pem" stunnel-rsyncd.conf
sed -i "s|config=/etc/rsync-ssl/rsyncd.conf|config=/ffp/etc/rsync-ssl/rsyncd.conf|g" stunnel-rsyncd.conf
# Copy  start-up script stunnel-rsync script and sample config
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/rsyncd.sh ${BUILDDIR}/ffp/start/
install -m 0755 stunnel-rsync ${BUILDDIR}/ffp/bin/
mkdir -p ${BUILDDIR}/ffp/etc/examples
install -m 0644 stunnel-rsyncd.conf ${BUILDDIR}/ffp/etc/examples/
# Make standard config
cat > ${BUILDDIR}/ffp/etc/examples/rsyncd.conf << EOF
# This must be root for rsync to use chroot -- rsync will drop permissions:
setuid = root
setgid = root
max connections = 4
pid = /ffp/var/run/rsyncd.pid
#output = /ffp/var/log/rsyncd.log
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
compression = rle

EOF

cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
# Create postinstall script to remove old start-up script
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/rsyncd.sh|awk '{print $1}')
CHECKSUMCONF1=$(md5sum ${BUILDDIR}/ffp/etc/examples/${PACKAGENAME}d.conf|awk '{print $1}')
CHECKSUMCONF2=$(md5sum ${BUILDDIR}/ffp/etc/examples/stunnel-${PACKAGENAME}d.conf|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

# Replace current start script if newer exists
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

DATE=\$(date "+%Y%m%d_%H%M%S")

if	[ -f /ffp/start/${PACKAGENAME}d.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}d.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
	if	[ -f /ffp/start/${PACKAGENAME}d.sh ]; then
		mv /ffp/start/${PACKAGENAME}d.sh /ffp/start/${PACKAGENAME}d.sh.old\${DATE}
		chmod 644 /ffp/start/${PACKAGENAME}d.sh.old\${DATE}
		mv /ffp/start/${PACKAGENAME}d.sh.new /ffp/start/${PACKAGENAME}d.sh
	else
		mv /ffp/start/${PACKAGENAME}d.sh.new /ffp/start/${PACKAGENAME}d.sh
	fi
fi
if	[ -f /ffp/start/${PACKAGENAME}d.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}d.sh.new|awk '{print \$1}') != $CHECKSUM ]; then
	rm /ffp/start/${PACKAGENAME}d.sh.new
fi
if	[ -f /ffp/etc/examples/${PACKAGENAME}d.conf.new ] && [ \$(md5sum /ffp/etc/examples/${PACKAGENAME}d.conf.new|awk '{print \$1}') = $CHECKSUMCONF1 ]; then
	mv /ffp/etc/examples/${PACKAGENAME}d.conf.new /ffp/etc/examples/${PACKAGENAME}d.conf
fi
if	[ -f /ffp/etc/examples/stunnel-${PACKAGENAME}d.conf.new ] && [ \$(md5sum /ffp/etc/examples/stunnel-${PACKAGENAME}d.conf.new|awk '{print \$1}') = $CHECKSUMCONF2 ]; then
	mv /ffp/etc/examples/stunnel-${PACKAGENAME}d.conf.new /ffp/etc/examples/stunnel-${PACKAGENAME}d.conf
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
for pkgname in ${PACKAGENAME}; do
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