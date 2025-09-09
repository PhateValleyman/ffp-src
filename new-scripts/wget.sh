#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=wget
VERSION=1.17.1
SOURCEURL=http://ftp.gnu.org/gnu/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=http://www.gnu.org/software/wget
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
#wget-1.12 has bug checking Subject Alternative Names (SAN) properly.
#https://docs.fastly.com/guides/tls/why-do-i-see-tls-certificate-errors-when-using-wget
#https://wiki.openwrt.org/doc/howto/wget-ssl-certs
wget -nv ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.tar.xz
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
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--sysconfdir=/ffp/etc \
	--with-ssl=openssl \
	--disable-nls \
	--disable-pcre
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
GNU Wget is a free software package for retrieving files using HTTP, HTTPS and FTP, the most
widely-used Internet protocols. It is a non-interactive commandline tool, so it may easily be
called from scripts, cron jobs, terminals without X-Windows support, etc.  
License: GPLv3
Version:${VERSION}
Homepage:${HOMEURL}
Depends on these packages:
br2:libiconv s:openssl br2:uClibc-solibs s:util-linux uli:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
for pkgname in gcc uClibc ${PACKAGENAME}; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
# Add path to cert.pem in wgetrc
if [ -f ${BUILDDIR}/ffp/etc/wgetrc ]; then
	cat >> ${BUILDDIR}/ffp/etc/wgetrc <<- EOF

	# CA Root Certificates location
	# Get a fresh bundle of CA Root Certificates in one file from trusted source http://curl.haxx.se
	# /ffp/bin/wget -nv http://curl.haxx.se/ca/cacert.pem -O /ffp/etc/ssl/cert.pem
	#ca_certificate=/ffp/etc/ssl/cert.pem

	EOF
fi
# Include bundle of CA Root Certificates in distribution
mkdir -p ${BUILDDIR}/ffp/etc/ssl
wget -nv http://curl.haxx.se/ca/cacert.pem -O ${BUILDDIR}/ffp/etc/ssl/cert.pem
# Change default preferred protocol to IPv4
sed -i '/#prefer-family/c\prefer-family = IPv4' ${BUILDDIR}/ffp/etc/wgetrc
# Create postinstall script to remove old cert.pem and config file /ffp/etc/wgetrc
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/ssl/cert.pem|awk '{print $1}')
CHECKSUM2=$(md5sum ${BUILDDIR}/ffp/etc/wgetrc|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

cert_file=/ffp/etc/ssl/cert.pem

if [ -f \$cert_file.new ] && [ \$(md5sum \$cert_file.new|awk '{print \$1}') = $CHECKSUM ]; then
   mv \$cert_file.new \$cert_file
fi
if [ -f \$cert_file.new ] && [ \$(md5sum \$cert_file.new|awk '{print \$1}') != $CHECKSUM ]; then
   rm \$cert_file.new
fi

DATE=\$(date "+%Y%m%d_%H%M%S")
cfg_file=/ffp/etc/wgetrc

if  [ -f \$cfg_file.new ] && [ \$(md5sum \$cfg_file.new|awk '{print \$1}') = $CHECKSUM2 ]; then
   if  [ -f \$cfg_file ]; then
       mv \$cfg_file \$cfg_file.old\${DATE}
       mv \$cfg_file.new \$cfg_file
   else
       mv \$cfg_file.new \$cfg_file
   fi
fi
if  [ -f \$cfg_file.new ] && [ \$(md5sum \$cfg_file.new|awk '{print \$1}') != $CHECKSUM2 ]; then
    rm \$cfg_file.new
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