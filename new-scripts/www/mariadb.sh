#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
CFLAGS="$CFLAGS -fno-strict-aliasing -Wno-cast-align"
CXXFLAGS="$CXXFLAGS -fno-strict-aliasing -Wno-cast-align"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=mariadb
VERSION=10.0.21
SOURCEURL=https://downloads.mariadb.org/interstitial/${PACKAGENAME}-${VERSION}/source/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=https://mariadb.org/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/www"
PKGDIRBACKUP="/ffp/funpkg/additional/www"
export PATH PKGDIR CFLAGS CXXFLAGS
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
sed -i "s@data/test@\${INSTALL_MYSQLTESTDIR}@g" sql/CMakeLists.txt
mkdir build
cd build
cmake .. \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/ffp \
	-DINSTALL_SYSCONFDIR=/ffp/etc/mysql \
	-DMYSQL_DATADIR=/ffp/var/lib/mysql \
	-DINSTALL_UNIX_ADDRDIR=/ffp/var/run/mysqld/mysqld.sock \
	-DINSTALL_MANDIR=share/man \
	-DINSTALL_MYSQLSHAREDIR=share/mysql \
	-DINSTALL_SUPPORTFILESDIR=share/mysql \
	-DINSTALL_PLUGINDIR=lib/mysql/plugin \
	-DINSTALL_SBINDIR=sbin \
	-DINSTALL_SCRIPTDIR=bin \
	-DINSTALL_SQLBENCHDIR=share/mysql/bench \
	-DINSTALL_DOCDIR=share/mysql/docs \
	-DINSTALL_DOCREADMEDIR=share/mysql/docsreadme \
	-DINSTALL_MYSQLTESTDIR=share/mysql/test \
	-DWITH_EXTRA_CHARSETS=complex \
	-DWITH_EMBEDDED_SERVER=ON \
	-DWITH_READLINE=OFF \
	-DWITH_ZLIB=system \
	-DWITH_SSL=system \
	-DWITH_PCRE=system \
	-DTMPDIR=/ffp/var/lib/mysql/tmp \
	-DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG $CXXFLAGS" \
	-DCMAKE_C_FLAGS_RELEASE="-DNDEBUG $CFLAGS" \
	-DHAVE_GCC_ATOMIC_BUILTINS=0
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
MariaDB is a community-developed fork and a drop-in replacement for the MySQL relational database
management system.
License: GPLv2
Version:${VERSION}
Homepage:${HOMEURL}
Depends on these packages:
br2:gcc-solibs br2:libiconv br2:libxml2 br2:ncurses br2:openssl br2:pcre br2:uClibc-solibs s:xz- uli:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unnecessary stuff
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
if [ -d ${BUILDDIR}/ffp/share/mysql/docs ]; then
   rm -rf ${BUILDDIR}/ffp/share/mysql/docs
fi
if [ -d ${BUILDDIR}/ffp/share/mysql/test ]; then
   rm -rf ${BUILDDIR}/ffp/share/mysql/test
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
# Remove init script, copy config file and examples to right place
rm -rf ${BUILDDIR}/ffp/etc/mysql/init.d
cp -a ${BUILDDIR}/ffp/share/mysql/my-medium.cnf ${BUILDDIR}/ffp/etc/mysql/my.cnf
mkdir -p ${BUILDDIR}/ffp/etc/mysql/examples
for configfile in ${BUILDDIR}/ffp/share/mysql/my-*.cnf; do
	cp -a "$configfile" ${BUILDDIR}/ffp/etc/mysql/examples/
done
# Create other required dirs (data,for temp files, socket and groonga logs)
install -dm700 ${BUILDDIR}/ffp/var/lib/mysql
install -dm700 ${BUILDDIR}/ffp/var/lib/mysql/tmp
install -dm700 ${BUILDDIR}/ffp/var/run/mysqld
install -dm700 ${BUILDDIR}/ffp/var/log/groonga
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"