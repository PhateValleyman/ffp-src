#!/ffp/bin/sh

#
# With new gcc 4.9.2 compiling libtorrent requires more swapfile space
# Increase it or you will run into out of memory issues
# http://www.cyberciti.biz/faq/linux-add-a-swap-file-howto/
# http://forum.nas-central.org/viewtopic.php?f=249&t=7569
#

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
TMPDIR="/mnt/HD_a2/tmp"
### Suppress deprecated functions warnings
export CPPFLAGS="$CPPFLAGS -Wno-deprecated-declarations -Wno-unused-function"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=libtorrent
SOURCEURL=svn://svn.code.sf.net/p/${PACKAGENAME}/code/branches/RC_1_0
HOMEURL=http://www.rasterbar.com/products/libtorrent/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/deluge"
PKGDIRBACKUP="/ffp/funpkg/additional/deluge"
### Set install directory for python bindings (module)
PYTHON_INSTALL_PARAMS="--root=${BUILDDIR}"
export PATH TMPDIR PKGDIR PYTHON_INSTALL_PARAMS
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
### Create new swap space
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
#Get libtorrent source code from svn repository:
svn checkout -q ${SOURCEURL} ${PACKAGENAME}
#svn checkout -q -r 10611 ${SOURCEURL} ${PACKAGENAME}
REVISION=$(svn info ${BUILDDIR}/${PACKAGENAME}/|grep 'Revision:'|awk -F ' ' '{print $2}')
VERSION=$(grep 'VERSION =' ${BUILDDIR}/${PACKAGENAME}/Jamfile|awk -F ' ' '{print $3}')_svn${REVISION}
mv ${PACKAGENAME} ${PACKAGENAME}-${VERSION}
cd ${PACKAGENAME}-${VERSION}
# Change optimization level to speed instead space in python bindings
sed -i 's|optimization=space|optimization=speed|' bindings/python/setup.py
# Remove whitespaces at the end of row in file or autoreconf will fail
sed -i 's/ $//' test/Makefile.am
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
# Run libtool and autoreconf
./autotool.sh
# Adapt scripts to FFP prefix after autoreconf
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
# Correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
### Old uClibc doesn't has function posix_fallocate so we will disable it:
### Fixes error: 'posix_fallocate' was not declared in this scope
### http://comments.gmane.org/gmane.network.bit-torrent.libtorrent/3345
#sed -i 's|TORRENT_HAS_FALLOCATE 1|TORRENT_HAS_FALLOCATE 0|g' include/libtorrent/config.hpp
### Fix error: 'INT64_MAX' was not declared in this scope
### http://code.google.com/p/libtorrent/issues/detail?id=339
#sed -i '/config.hpp"/i\#define __STDC_LIMIT_MACROS 1' src/utp_stream.cpp
#sed -i '/cstdint.hpp>/a\#include <stdint.h>' src/utp_stream.cpp
#sed -i '/config.hpp"/i\#define __STDC_LIMIT_MACROS 1' src/lazy_bdecode.cpp
#sed -i '/cstring>/a\#include <stdint.h>' src/lazy_bdecode.cpp
##### Disable utp to improve speed of downloading and maybe seeding?
sed -i 's|enable_incoming_utp(true)|enable_incoming_utp(false)|g' src/session.cpp
sed -i 's|enable_outgoing_utp(true)|enable_outgoing_utp(false)|g' src/session.cpp
#####
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--exec-prefix=/ffp \
	--enable-shared \
	--disable-static \
	--with-libgeoip \
	--with-libiconv \
	--enable-python-binding \
	--with-boost=/ffp \
	--with-openssl=/ffp
make
make check
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME}:
Libtorrent is a feature complete C++ bittorrent implementation, focusing on efficiency and
scalability. It runs on embedded devices as well as desktops. It boasts a well documented 
library interface that is easy to use.The main goals of libtorrent are:
	#to be cpu efficient
	#to be memory efficient
	#to be very easy to use
License:BSD
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:geoip br2:boost br2:libiconv br2:python-2.7.* br2:gcc-solibs br2:uClibc-solibs s:openssl s:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
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
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"