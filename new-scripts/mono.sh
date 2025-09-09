#!/ffp/bin/sh

# BUG, emby?
# When running emby terminal outputs:
# Got a bad hardware address length for an AF_PACKET 16 8
set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
TMPDIR="/mnt/HD_a2/tmp"
CFLAGS="$CFLAGS -Wno-strict-prototypes -Wno-missing-prototypes -Wno-missing-declarations"
CXXFLAGS="$CFLAGS"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=mono
VERSION=4.4.1
PATCHVERSION=0
SOURCEURL=http://download.mono-project.com/sources/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.${PATCHVERSION}.tar.bz2
HOMEURL=http://www.mono-project.com/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR CFLAGS CXXFLAGS TMPDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
### Create new swap space 1GB
newswapfile="/i-data/7cf371c4/.zyxel/nsa310swapfile"
oldswapfile="/i-data/7cf371c4/.zyxel/swap_ul6545p"
if	[ -f $newswapfile ]; then
	if	[ "$(cat /proc/swaps | awk 'NR == 2 {print $1}')" = "$oldswapfile" ]; then
		swapon $newswapfile
		swapoff $oldswapfile
	fi
else
	# Create 1 GB swap file
	dd if=/dev/zero of=$newswapfile bs=1M count=1024
	mkswap $newswapfile
	swapon $newswapfile
	swapoff $oldswapfile
fi
echo "Current swapfile in use is:"
swapon -s
# Create build, tmp and pkgs directories, if required
for DIR in ${BUILDDIR} ${TMPDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
wget -nv ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.${PATCHVERSION}.tar.bz2
cd ${PACKAGENAME}-${VERSION}
# Apply upstream patches to fix build
#wget -nv https://github.com/mono/mono/commit/d40a434c6052a4a521f674108d3def9c8b829e5a.patch -O ${PACKAGENAME}1.patch
#wget -nv https://github.com/mono/mono/commit/afd7d742ab4b72645e3e9c70ed917e9b3f40fffe.patch -O ${PACKAGENAME}2.patch
#wget -nv https://github.com/mono/mono/commit/150e8a86b7f63029d6f50d45e9781f9055e917ff.patch -O ${PACKAGENAME}3.patch
#sed -i 's|../sgen/libmonosgen.la ||' ${PACKAGENAME}2.patch
#for patches in ${PACKAGENAME}?.patch; do
#    patch -p1 < $patches
#done
# Apply patches to adapt for uClibc system
wget -e robots=off -nv -np -nd -H -r --level=1 -A patch http://git.buildroot.net/buildroot/plain/package/mono/
for patches in ????-*.patch; do
    patch -p1 < $patches
done
autoreconf -fi
# Adapt interpreters of scripts to FFP prefix
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
	--bindir=/ffp/bin \
	--sbindir=/ffp/bin \
	--enable-minimal=profiler,debug \
	--disable-nls \
	--disable-gtk-doc \
	--with-mcs-docs=no
#
# --disable-static \
# --with-ikvm-native=no \
# --enable-small-config=yes \
# Not elegant, but should be working hack to resolve warning:
#libtool: line 4401: warning: setlocale: LC_MESSAGES: cannot change locale (en_US)
#libtool: line 4401: warning: setlocale: LC_COLLATE: cannot change locale (en_US)
#libtool: line 4401: warning: setlocale: LC_MESSAGES: cannot change locale (en_US)
sed -i 's| LC_CTYPE LC_COLLATE LC_MESSAGES||' libtool
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Mono is a cross platform, open source implementation of the .NET framework including runtime and compiler.
License: MITX11, GPL, LGPL2.1, MPL
Version:${VERSION}.${PATCHVERSION}
Homepage:${HOMEURL}
Depends on these packages:
br2:gcc-solibs br2:libiconv br2:sqlite br2:uClibc-solibs uli:zlib uli:libxslt s:libgcrypt s:libgpg-error
br2:libxml2 br2:ncurses br2:readline

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
# Adapt interpreters of new scripts (created during build) to FFP prefix before making package
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
# Change all instances of libc.so.6 (glibc) to libc.so.0 (uClibc) in config
sed -i 's|libc.so.6|libc.so.0|g' ${BUILDDIR}/ffp/etc/mono/config
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
if [ -d ${BUILDDIR}/ffp/install ]; then
   mv ${BUILDDIR}/ffp/install/* ${BUILDDIR}/install
   rm -rf ${BUILDDIR}/ffp/install
fi
# Remove duplicate gcc and uclibc and in some cases package itself dependencies requirements
for pkgname in gcc uClibc ${PACKAGENAME}; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
makepkg ${PACKAGENAME} ${VERSION}.${PATCHVERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}.${PATCHVERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Build duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"