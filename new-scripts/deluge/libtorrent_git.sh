#!/ffp/bin/sh
set -e
#
# With new gcc 4.9.2 compiling libtorrent requires more swapfile space
# Increase it or you will run into out of memory issues
# http://www.cyberciti.biz/faq/linux-add-a-swap-file-howto/
# http://forum.nas-central.org/viewtopic.php?f=249&t=7569
#
#!!!!!!!!!! Since version 1.0.9 new issue> Uninstall currently installed libtorrent version package either way
# python bindings library links to current (old) version libtorrent library in /ffp/lib!!!!!!!
# This problem can be related (untested) with configure option --enable-export-all or with LDFLAGS

unset LDFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
TMPDIR="/mnt/HD_a2/tmp"
### Suppress deprecated functions warnings
CPPFLAGS="$CPPFLAGS -Wno-deprecated-declarations -Wno-unused-function"
CXXFLAGS="$CXXFLAGS -std=c++11"
### Solves crashes on armv7, but seems like makes deluge crash on armv5
### https://github.com/arvidn/libtorrent/issues/317
#CXXFLAGS="$CXXFLAGS -DBOOST_SP_USE_PTHREADS"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=libtorrent
SOURCEURL=https://github.com/arvidn/libtorrent
GITBRANCH=RC_1_1
HOMEURL=http://www.rasterbar.com/products/libtorrent/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/deluge"
PKGDIRBACKUP="/ffp/funpkg/additional/deluge"
### Set install directory for python bindings (module)
PYTHON_INSTALL_PARAMS="--root=${BUILDDIR}"
export PATH TMPDIR PKGDIR PYTHON_INSTALL_PARAMS CPPFLAGS CXXFLAGS
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
### Create new swap space
newswapfile="/i-data/7cf371c4/.zyxel/nsa310swapfile"
if	! grep "$newswapfile" /proc/swaps >/dev/null
then
	if	[ -f "$newswapfile" ]
	then
		chmod 600 "$newswapfile"
		mkswap "$newswapfile"
		swapon "$newswapfile"
	else
		# Create 1 GB swap file
		dd if=/dev/zero of="$newswapfile" bs=1M count=1024
		chmod 600 "$newswapfile"
		mkswap "$newswapfile"
		swapon "$newswapfile"
	fi
fi
echo "Current swapfile(s) in use is:"
swapon -s
# Create build, tmp and pkgs directories, if required
for DIR in ${BUILDDIR} ${TMPDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
#Get libtorrent source code from stable version git branch:
git clone -q -b ${GITBRANCH} ${SOURCEURL} ${PACKAGENAME}
### Revert back to 1.09 release commit for compatibility with deluge 1.3.13 (2e6685c not working)
### Revert back to 1.06 release commit for compatibility with deluge 1.3.13 0f2f144
###git --work-tree=${PACKAGENAME} --git-dir=${PACKAGENAME}/.git reset --hard 2e6685c
###
REVISION=$(git --work-tree=${PACKAGENAME} --git-dir=${PACKAGENAME}/.git rev-parse --short HEAD)
VERSION=$(grep 'VERSION =' ${PACKAGENAME}/Jamfile|awk -F ' ' '{print $3}')_git${REVISION}
mv ${PACKAGENAME} ${PACKAGENAME}-${VERSION}
cd ${PACKAGENAME}-${VERSION}
#RC_1_1 build will fail, due to missing preadv and pwritev syscalls support in uClibc
#https://github.com/arvidn/libtorrent/issues/776
#Disable use of these syscalls
#####NOTE: uClibc-ng added support of these syscalls in master branch. Hopefully will be supported since 1.0.23
if	[ "${GITBRANCH}" == "RC_1_1" ]
then
	sed -i '0,/TORRENT_USE_PREADV 1/s//TORRENT_USE_PREADV 0/' include/libtorrent/config.hpp
	sed -i '0,/TORRENT_USE_PREAD 0/s//TORRENT_USE_PREAD 1/' include/libtorrent/config.hpp
fi
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
##### Since 1.0.10 version option --with-libgeoip is deprecated
##### For debug build use additionally --enable-debug=yes --enable-logging=default and don't use makepkg, because it strips debug symbols from libs
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--exec-prefix=/ffp \
	--enable-shared \
	--disable-static \
	--with-libiconv \
	--enable-python-binding \
	--with-boost=/ffp \
	--with-openssl=/ffp \
	--with-libgeoip
make
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
boost libiconv python-2.7.* gcc-solibs uClibc-solibs openssl zlib

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
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from list of dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Add python-2.7.* and boost to list of deps (new boost package is not yet uploaded to repo)
sed -i "s|\<python\>|python-2.7.*|" ${BUILDDIR}/install/DEPENDS
sed -i '/^python/ d' ${BUILDDIR}/install/slack-required
cat >> ${BUILDDIR}/install/slack-required <<- EOF
python >= 2.7.13-arm-1
python < 2.8.0
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"