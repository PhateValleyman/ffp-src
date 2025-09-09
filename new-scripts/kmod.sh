#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=kmod
VERSION="23"
SOURCEURL=https://www.kernel.org/pub/linux/utils/kernel/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=http://git.kernel.org/?p=utils/kernel/kmod/kmod.git;a=summary
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
# Adapt test files to zyxel's NAS GPL source  
sed -i 's|libc.so.6|libc.so.0|g' testsuite/path.c testsuite/uname.c
#files=$(grep -rl '/lib/modules' testsuite) && echo $files | xargs sed -i 's|/lib/modules|/ffp/lib/modules|g'
#sed -i 's|/lib/modules|/ffp/lib/modules|' testsuite/test-testsuite.c testsuite/test-depmod.c
for testfile in testsuite/module-playground/*.c
do
    sed -i 's|<linux/printk.h>|<config/printk.h>|' $testfile
    sed -i 's|pr_warn|pr_warning|' $testfile
done
# Adapt config dirs paths to ffp prefix
sed -i 's|/run/modprobe.d|/ffp/run/modprobe.d|' libkmod/libkmod.c
sed -i 's|/lib/modprobe.d|/ffp/lib/modprobe.d|' libkmod/libkmod.c
sed -i 's|/run/depmod.d|/ffp/run/depmod.d|' tools/depmod.c 
sed -i 's|/lib/depmod.d|/ffp/lib/depmod.d|' tools/depmod.c 
sed -i 's|/lib/modules|/ffp/lib/modules|' libkmod/libkmod.c tools/{depmod.c,static-nodes.c}
#sed -i 's|/lib/modules|/ffp/lib/modules|' libkmod/libkmod.c tools/{depmod.c,static-nodes.c,modprobe.c,modinfo.c}
./configure --prefix=/ffp \
	--bindir=/ffp/bin \
	--libdir=/ffp/lib \
	--sysconfdir=/ffp/etc \
	--with-rootlibdir=/ffp/lib \
	--enable-tools \
	--disable-gtk-doc-html \
	--with-xz \
	--with-zlib
make
# Create symlinks for gcc, ar and linker, so they can work with zyxel source.
# Testsuite needs to compile testing modules
# 6 tests will fail, because testsuite doesn't support /ffp prefix
ln -sf /ffp/bin/ar /ffp/bin/arm-linux-ar
ln -sf /ffp/bin/gcc /ffp/bin/arm-linux-gcc
ln -sf /ffp/bin/ld /ffp/bin/arm-linux-ld
make check KDIR=/mnt/HD_a2/zyxel_gpl/trunk/linux-2.6.31.8 || true
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
The Kmod package contains library and utilities for management kernel modules
License: LGPLv2.1+ for libkmod, testsuite and helper libraries, GPLv2+ for tools
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:uClibc-solibs s:xz- uli:zlib

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
if [ -d ${BUILDDIR}/ffp/install ]; then
   mv ${BUILDDIR}/ffp/install/* ${BUILDDIR}/install
   rm -rf ${BUILDDIR}/ffp/install
fi
# Remove duplicate gcc and uclibc and in some cases package itself dependencies requirements
for pkgname in gcc uClibc ${PACKAGENAME}; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
# Create file to inform about conflic
cat > ${BUILDDIR}/install/slack-conflicts << EOF
module_utils
EOF
# Create symlinks for compatibility with Module-Init-Tools (previous handler of Linux kernel modules)
mkdir ${BUILDDIR}/ffp/sbin
cd ${BUILDDIR}/ffp/sbin
for tool in depmod insmod lsmod modinfo modprobe rmmod
do
    ln -s /ffp/bin/kmod "$tool"
done
cd ${BUILDDIR}
# Create directories for config files
install -dm755 ${BUILDDIR}/{ffp/etc,ffp/lib}/{depmod,modprobe}.d
cat > ${BUILDDIR}/ffp/lib/depmod.d/search.conf << EOF
# /ffp/lib/depmod.d/search.conf
# This file is a part of kmod ffp package
# Do not edit it.
# For userland editing create and use /ffp/etc/depmod.d/search.conf instead this file
# search directive specifies additional paths in /ffp/lib/modules/\$(uname -r) to search for modules.

search updates extra built-in

EOF
# Create postinstall script to regenerate modules database.
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh

if	[ -d "/ffp/lib/modules/$(uname -r)" ]
then
	/ffp/sbin/depmod -a
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