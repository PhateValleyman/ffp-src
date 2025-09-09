#!/ffp/bin/bash

### TODO:start script php-fpm

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=php
VERSION=7.1.4
SOURCEURL=http://www.php.net/distributions/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=http://www.php.net/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/www"
PKGDIRBACKUP="/ffp/funpkg/additional/www"
EXTENSION_DIR=/ffp/lib/php/modules
PEAR_INSTALLDIR=/ffp/share/pear
export PATH PKGDIR EXTENSION_DIR PEAR_INSTALLDIR
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
tar xf "${SOURCEURL##*/}"
cd ${PACKAGENAME}-${VERSION}
# Adapt scripts to FFP prefix
sed -i 's|/usr/local|/ffp|g' configure
sed -i 's|/usr|/ffp|g' configure
sed -i 's|/bin/sh|/ffp/bin/sh|g' configure
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
# Some changes in config files
sed -i 's|;chdir = /var/www|chdir = /ffp/var/www|' sapi/fpm/www.conf.in

# Always static:
# date, ereg, filter, libxml, reflection, spl: not supported
# hash: for PHAR_SIG_SHA256 and PHAR_SIG_SHA512
# session: dep on hash, used by soap and wddx
# pcre: used by filter, zip
# pcntl, readline: only used by CLI sapi
# openssl: for PHAR_SIG_OPENSSL
# zlib: used by image

# 	option --with-mysqli=shared,/ffp/bin/mysql_config --enable-embedded-mysqli \ leads to error
# /mnt/HD_a2/build/php-7.1.4/ext/mysqli/mysqli_embedded.c:63:8: error: too many arguments to function 'zend_hash_get_current_data_ex'
# https://forum.nas-central.org/viewtopic.php?f=249&t=18603
./configure \
	--prefix=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--sbindir=/ffp/bin \
	--sysconfdir=/ffp/etc/php \
	--enable-fpm \
	--with-layout=GNU \
	--with-config-file-path=/ffp/etc/php \
	--with-config-file-scan-dir=/ffp/etc/php/conf.d \
	--enable-hash \
	--enable-session \
	--enable-posix=shared \
	--enable-sockets=shared \
	--enable-sysvsem=shared \
	--enable-calendar=shared \
	--enable-ctype=shared \
	--enable-dba=shared \
	--enable-dom=shared \
	--with-gd=shared --enable-gd-native-ttf \
	--enable-xmlreader=shared \
	--enable-libxml --enable-simplexml=shared --enable-soap=shared --with-libxml-dir=/ffp \
	--enable-mbstring=shared --enable-mbregex=shared \
	--enable-tokenizer=shared \
	--enable-ftp=shared \
	--enable-pcntl \
	--with-pcre-regex=/ffp --with-pcre-dir=/ffp \
	--with-sqlite3=shared,/ffp --with-pdo-sqlite=shared,/ffp \
	--with-pdo-mysql=shared,/ffp \
	--with-mysql-sock=/ffp/var/run/mysqld/mysqld.sock \
	--with-mysqli=shared,mysqlnd \
	--with-zlib=/ffp --with-zlib-dir=/ffp \
	--enable-zip=shared,/ffp \
	--with-bz2=shared,/ffp \
	--with-openssl=/ffp --with-openssl-dir=/ffp \
	--with-gdbm=shared,/ffp \
	--with-gmp=shared,/ffp \
	--with-curl=shared,/ffp \
	--with-jpeg-dir=/ffp \
	--with-png-dir=/ffp \
	--enable-exif=shared,/ffp \
	--with-freetype-dir=/ffp \
	--with-gettext=shared,/ffp \
	--with-iconv=shared,/ffp --with-iconv-dir=/ffp \
	--with-icu-dir=/ffp \
	--enable-intl=shared \
	--with-readline=/ffp \
	--with-xmlrpc=shared \
	--with-xsl=shared,/ffp \
	--with-mcrypt=shared,/ffp \
	--enable-maintainer-zts
make
make INSTALL_ROOT=${BUILDDIR} install
# Create directories for user config files and adjust global configs 
mkdir -p ${BUILDDIR}/ffp/etc/php/conf.d
mkdir -p ${BUILDDIR}/ffp/etc/php/php-fpm.d
mkdir -p ${BUILDDIR}/ffp/var/www
mv php.ini-production ${BUILDDIR}/ffp/etc/php/php.ini
sed -i 's|;open_basedir =|open_basedir = /ffp/var/www/:/tmp/:/ffp/share/pear/|' ${BUILDDIR}/ffp/etc/php/php.ini
sed -i 's|;include_path = ".:/php/includes"|include_path = ".:/ffp/share/pear"|' ${BUILDDIR}/ffp/etc/php/php.ini
sed -i 's|; extension_dir = "./"|extension_dir = "/ffp/lib/php/modules"|' ${BUILDDIR}/ffp/etc/php/php.ini
sed -i 's|.dll|.so|g' ${BUILDDIR}/ffp/etc/php/php.ini
mv ${BUILDDIR}/ffp/etc/php/php-fpm.conf.default ${BUILDDIR}/ffp/etc/php/php-fpm.conf
mv ${BUILDDIR}/ffp/etc/php/php-fpm.d/www.conf.default ${BUILDDIR}/ffp/etc/php/php-fpm.d/www.conf
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
PHP is an HTML-embedded scripting language.  Primarily used in dynamic web sites, it allows for programming
code to be directly embedded into the HTML markup. It is a popular general-purpose scripting language
that is especially suited to web development. Fast, flexible and pragmatic, PHP powers everything from
your blog to the most popular websites in the world.

License(s): PHP (BSD-style Open Source license) and Zend and BSD
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
#Depends on these packages:
#s:bzip2 br2:curl br2:freetype br2:gcc-solibs br2:gettext br2:gmp br2:icu4c br2:libiconv s:libjpeg
#s:libpng br2:libxml2 br2:mariadb br2:ncurses br2:openssl br2:pcre br2:readline br2:sqlite
#br2:uClibc-solibs s:xz- uli:zlib
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unnecessary stuff
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# PHP sometimes likes to throw some junk in the INSTALL_ROOT directory
rm -rf .channels .depdb .depdblock .filemap .lock .registry
# Remove empty dir
rm -rf ${BUILDDIR}/ffp/include/php/include
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
# Remove package itself from dependencies requirements
sed -i "s| \<${PACKAGENAME}\>||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Add libmcrypt as additional dependency, since it not uploaded to repo yet
sed -i '1 s|$| libmcrypt|' ${BUILDDIR}/install/DEPENDS
cat >> ${BUILDDIR}/install/slack-required <<- EOF
libmcrypt
EOF
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"