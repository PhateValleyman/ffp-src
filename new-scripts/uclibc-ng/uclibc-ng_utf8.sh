#!/ffp/bin/bash

#http://lists.uclibc.org/pipermail/uclibc/2011-February/044822.html
#http://ftp.osuosl.org/pub/manulix/scripts/build-scripts/PATCHCMDS/
#http://lists.uclibc.org/pipermail/uclibc-cvs/2011-September/029861.html
#http://stackoverflow.com/questions/602912/how-do-you-echo-a-4-digit-unicode-character-in-bash
#http://repo.or.cz/w/glibc.git/blob_plain/1b188a651ec0af5dad0f368afdc6fdfbfd8dfce2:/localedata/charmaps/KOI8-RU
#http://www.tldp.org/HOWTO/Danish-HOWTO-5.html

# Some info and patches
#http://gentoo.cs.nctu.edu.tw/gentoo-portage/sys-libs/uclibc-ng/
#https://git.buildroot.net/buildroot/tree/package/uclibc
#https://github.com/Optware/Optware-ng/tree/master/sources/buildroot-armv5eabi-ng-legacy
#https://github.com/Entware-ng/Entware-ng/tree/master/toolchain/uClibc

# Toolchain build order: kernel-headers->uClibc->binutils->gcc->binutils->uClibc
# 20170907 disabled extra build warnings (EXTRA_WARNINGS is not set) 
# 20170830 Added UCLIBC_SV4_DEPRECATED=y required for building gcc-go, because of ustat() syscall.

set -e
unset CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
SHELL="/ffp/bin/bash"
CONFIG_SHELL="$SHELL"
PATH="/ffp/bin:/ffp/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
SOURCEDIR="/mnt/HD_a2/build"
BUILDDIR="/mnt/HD_a2/build/tmp"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
PACKAGENAME="uClibc"
PACKAGENAME2="uClibc-solibs"
SOURCEURL="git://uclibc-ng.org/git/uclibc-ng"
HOMEURL="http://www.uclibc-ng.org/"
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}-ng"
PKGDIRBACKUP="/ffp/funpkg/additional/${PACKAGENAME}-ng"
PKGREL=2
export PATH CONFIG_SHELL SHELL PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @"${STARTTIME}" +%F\ %T)"
for dir in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d "$dir" ]
	then
	   mkdir -p "$dir"
	fi
done
cd ${SOURCEDIR}
git clone -q ${SOURCEURL} ${PACKAGENAME}
MAJOR_VERSION="$(grep '^MAJOR_VERSION' ${PACKAGENAME}/Rules.mak | awk '{print $3}')"
MINOR_VERSION="$(grep '^MINOR_VERSION' ${PACKAGENAME}/Rules.mak | awk '{print $3}')"
SUBLEVEL="$(grep '^SUBLEVEL' ${PACKAGENAME}/Rules.mak | awk '{print $3}')"
REVISION="$(git --work-tree=${PACKAGENAME} --git-dir=${PACKAGENAME}/.git rev-parse --short HEAD)"
VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${SUBLEVEL}"
GITVERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${SUBLEVEL}_git${REVISION}"
mv ${PACKAGENAME} ${PACKAGENAME}-${VERSION}
cd ${PACKAGENAME}-${VERSION}
# Apply patches to resolve conflict with 2.6.31.8 kernel headers and avoid redefinition
# Plus adapt ldso, ldd, lddconfig, getaddrinfo config and abi version to /ffp prefix 
for patches in ${SCRIPTDIR}/patches-${VERSION}/????-*.patch
do
	patch -p1 < "$patches"
done
# Adapt executables to FFP prefix
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
# Adapt hardcoded paths
sed -i 's|RUNTIME_PREFIX=/|RUNTIME_PREFIX=/ffp/|' Makefile.in
sed -i 's|DEVEL_PREFIX=/usr/|DEVEL_PREFIX=/ffp/|' Makefile.in
sed -i 's|":/bin:/usr/bin";|":/ffp/bin:/bin:/usr/bin";|' librt/spawn.c libc/unistd/exec.c
sed -i 's|"/bin:/usr/bin"|"/ffp/bin:/bin:/usr/bin"|' libc/unistd/confstr.c
sed -i 's|/usr/include/asm/unistd.h|/ffp/include/asm/unistd.h|' libc/sysdeps/linux/sh/sysdep.h
sed -i 's|/usr/include/asm/unistd.h|/ffp/include/asm/unistd.h|' libc/sysdeps/linux/arm/sysdep.h
sed -i 's|"/usr/bin:/bin"|"/ffp/bin:/usr/bin:/bin"|' include/paths.h
sed -i 's|"/usr/bin:/bin:/usr/sbin:/sbin"|"/ffp/bin:/ffp/sbin:/usr/bin:/bin:/usr/sbin:/sbin"|' include/paths.h
sed -i 's|"/usr/share/man"|"/ffp/share/man"|' include/paths.h
sed -i 's|"/usr/bin/vi"|"/ffp/bin/vi"|' include/paths.h
sed -i 's|"/usr/sbin/sendmail"|"/ffp/sbin/sendmail"|' include/paths.h
sed -i 's|/usr/include/iconv.h|/ffp/include/iconv.h|' extra/locale/Makefile.in
sed -i 's|/usr/|/ffp/|g' extra/config/Makefile.kconfig extra/scripts/relinfo.pl
sed -i 's|/usr/|/ffp/|g' extra/config/lxdialog/check-lxdialog.sh
sed -i 's|/usr/|/ffp/|g' extra/scripts/MAKEALL
sed -i 's|"/usr/share/locale"|"/ffp/share/locale"|' extra/config/lkc.h
sed -i 's|PATH="/bin:/usr/bin"|PATH="/ffp/bin:/bin:/usr/bin"|' extra/scripts/getent
sed -i 's|PATH="${PATH}:/bin:/usr/bin"|PATH="${PATH}":/ffp/bin:/bin:/usr/bin"|' extra/scripts/getent
# Copy build config to sourcedir
# We need at least one UTF-8 locale to be present on system, to build uClibc locale data
# uClibc-1.0.26_gitea38f4d89-arm-2.txz-all_locales, uClibc-1.0.26_gitea38f4d89-arm-3.txz-minimal_locales
#cp -a ${SCRIPTDIR}/.config_${VERSION}_minimal_locales "$PWD"/.config
cp -a ${SCRIPTDIR}/.config_${VERSION}_all_locales "$PWD"/.config
# Confirm silently old config
make oldconfig
# Make uClibc-ng headers and libraries, then utils. Hardcode libraries runpath to /ffp/lib
make UCLIBC_EXTRA_LDFLAGS="-Wl,-rpath=/ffp/lib"
make utils UCLIBC_EXTRA_LDFLAGS="-Wl,-rpath=/ffp/lib"
# Install shared libs and make uClibc-ng-solibs package first
# Don't use install_runtime only, because libc.so will different in solibs and main package.
# make install does additional sed'ing for libc.so
#make PREFIX=${BUILDDIR} install_runtime
make PREFIX=${BUILDDIR} install
rm -rf ${BUILDDIR}/ffp/{bin,sbin,include}
find ${BUILDDIR}/ffp/lib ! -type d ! -name "*.so*" -exec rm {} +
##The following copy command installs some of symlinks and libc.so solib additionally:
# ld-uClibc.so -> ld-uClibc-1.0.22.so
# libc.so
# libthread_db.so -> libthread_db-1.0.22.so
##Do we really need them for runtime solibs package?
#cp -av lib/*.so* ${BUILDDIR}/ffp/lib/
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

uClibc-ng (aka µClibc-ng/pronounced yew-see-lib-see next generation) is a C library for developing
embedded Linux systems.It is much smaller than the GNU C Library, but nearly all applications
supported by glibc also work perfectly with uClibc-ng.
NOTE: This package contains the shared runtime libraries only.
License(s): GNU LGPL
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
br2:kernel-headers-2.6.31.8

IMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.
Other devices with kernel different from 2.6.31.8 are only partly compatible.

EOF
echo ${HOMEURL} >> ${BUILDDIR}/install/HOMEPAGE
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
echo -e "\e[1;34;42mIMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.\e[0m"
echo -e "\e[1;31;21mOther devices with kernel different from 2.6.31.8 are only partly compatible.\e[0m"

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
### Add conflict with uClibc and uClibc-solibs
### Disable conflicts temporary until package is named as uClibc
###
#cat > ${BUILDDIR}/install/slack-conflicts << 'EOF'
#uClibc
#uClibc-solibs
#EOF

# Since commit 2016 09 26 http://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/commit/?id=29ff9055c80efe77a7130767a9fcb3ab8c67e8ce
# uClibc-ng is using use a single shared libc. No more separate shared libraries are available.
# Let's make symlinks for compatibility with older builds < 1.0.17. and uClibc
cd ${BUILDDIR}/ffp/lib
# Add shared lib symlink for libuargp?
# Add shared lib symlink for tiny libiconv (in case it is enabled)?
for lib in libcrypt libdl libm libnsl libpthread librt libresolv libubacktrace libutil
do
	ln -s libuClibc-${VERSION}.so $lib.so
	ln -s libuClibc-${VERSION}.so $lib.so.0
done
ln -s  ld-uClibc-${VERSION}.so ld-uClibc.so
cd ${BUILDDIR}
# Create uClibc-ng-solibs package first
makepkg ${PACKAGENAME2} ${GITVERSION} ${PKGREL}
cp -a ${PKGDIR}/${PACKAGENAME2}-${GITVERSION}-arm-${PKGREL}.txz ${PKGDIRBACKUP}
cd ${SOURCEDIR}/${PACKAGENAME}-${VERSION}
# Install and make uClibc-ng package
make PREFIX=${BUILDDIR} install
make PREFIX=${BUILDDIR} install_utils
# Install getent utility
cp -av extra/scripts/getent ${BUILDDIR}/ffp/bin/
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Correct description and required dependencies for main uClibc-ng package
echo "${PACKAGENAME2} = ${GITVERSION}-arm-${PKGREL}" > ${BUILDDIR}/install/slack-required
sed -i 's|uClibc-ng-solibs|uClibc-ng|' ${BUILDDIR}/install/DESCR
sed -i '/^NOTE:/d' ${BUILDDIR}/install/DESCR
# Rebuild ld.so.cache right after installing package 
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
# Rebuild ld.so.cache after installing
if	[ -x /ffp/sbin/ldconfig ]
then
	/ffp/sbin/ldconfig
fi
echo -e "\e[1;34;42mIMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.\e[0m"
echo -e "\e[1;31;21mOther devices with kernel different from 2.6.31.8 are only partly compatible.\e[0m"

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Remove iconv implementation by uClibc-ng as much as possible (it is still available via shared libuClibc-1.0.26.so)
rm ${BUILDDIR}/ffp/bin/iconv
rm ${BUILDDIR}/ffp/include/iconv.h
rm ${BUILDDIR}/ffp/lib/libiconv.a
rm ${BUILDDIR}/ffp/lib/libiconv_pic.a
# Create main uClibc-ng package
makepkg ${PACKAGENAME} ${GITVERSION} ${PKGREL}
cp -a ${PKGDIR}/${PACKAGENAME}-${GITVERSION}-arm-${PKGREL}.txz ${PKGDIRBACKUP}
cd
rm -rf ${SOURCEDIR}
ENDTIME=$(date +"%s")
DIFF=$((ENDTIME-STARTTIME))
echo "End point:$(date -d @"${ENDTIME}" +%F\ %T)"
echo "Build duration: $((DIFF / 3600 )) hours $((DIFF / 60 % 60)) minutes and $((DIFF % 60)) seconds"