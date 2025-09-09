#!/ffp/bin/bash

set -e
SHELL="/ffp/bin/bash"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
GLIB_LIBDIR="/ffp/lib"
GLIB_LIBS="$(pkg-config --static --libs glib-2.0)"
GLIB_CFLAGS="$(pkg-config --cflags glib-2.0)"
BUILDDIR="/ffp/home/root/build/scripts"
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=mc
VERSION="4.8.29"
SOURCEURL=http://ftp.midnight-commander.org/${PACKAGENAME}-${VERSION}.tar.xz
#SOURCEURL=http://192.168.1.15:8181/Android/data/com.android.chrome/files/Download/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=http://www.midnight-commander.org/
#PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
#PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR GLIB_LIBDIR GLIB_LIBS GLIB_CFLAGS SHELL
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# For building static mc, we can use uClibc with UTF-8 support
#funpkg -u /mnt/HD_a2/ffp0.7arm/packages.backup/uClibc/uClibc-0.9.33.3_git-arm-5.txz
#funpkg -u /mnt/HD_a2/ffp0.7arm/packages.backup/uClibc/uClibc-solibs-0.9.33.3_git-arm-5.txz
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
#wget -nv ${SOURCEURL}
#tar xf ${PACKAGENAME}-${VERSION}.tar.xz
cd ${PACKAGENAME}-${VERSION}
# Adapt shell to ffp prefix
#autoreconf -vfi
LIBS="-lglib-2.0" ./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--with-sysroot=/ffp \
	--with-glib-static \
	--with-screen=ncursesw \
	--enable-charset \
	--disable-vfs \
	--enable-vfs-undelfs \
	--enable-vfs-smb \
	--with-smb-configdir=/ffp/etc/mc/samba \
	--with-smb-codepagedir=/ffp/etc/mc/samba \
	--disable-doxygen-doc \
	--disable-doxygen-html \
	--with-search-engine=glib \
	--with-homedir=/ffp/var/lib/mc \
	--enable-static-build
# Adapt executables to FFP prefix after configuration
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
colormake
colormake install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of Midnight Commander:
GNU Midnight Commander is a visual file manager, licensed under GNU General Public License and therefore
qualifies as Free Software. It's a feature rich full-screen text mode application that allows you to copy,
move and delete files and whole directory trees, search for files and run commands in the subshell.
Internal viewer and editor are included.
License: GPLv3+
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
Theoretically none. This package contains static mc binary. But some operations still requires external
utilities like diffutils for comparing files or extraction tools for decompressing files as example.

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
#rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
mkdir -p ${BUILDDIR}/ffp/etc/profile.d
#alias mc='SHELL=/ffp/bin/bash LANG=en_US.UTF-8 mc'
cat > ${BUILDDIR}/ffp/etc/profile.d/mc.sh << EOF
alias mc='LANG=en_US.UTF-8 mc'
alias mcedit='LANG=en_US.UTF-8 mcedit'
alias mcview='LANG=en_US.UTF-8 mcview'
alias mcdiff='LANG=en_US.UTF-8 mcdiff'

NCURSES_NO_UTF8_ACS=1
export NCURSES_NO_UTF8_ACS

EOF
chmod 755 ${BUILDDIR}/ffp/etc/profile.d/mc.sh
# Create postinstall script to remove old profile file /ffp/etc/profile.d/mc.sh
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/profile.d/mc.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

# Update mc profile
prof_file=/ffp/etc/profile.d/mc.sh

if  [ -f \$prof_file.new ] && [ \$(md5sum \$prof_file.new|awk '{print \$1}') = $CHECKSUM ]; then
    mv \$prof_file.new \$prof_file
fi
if  [ -f \$prof_file.new ] && [ \$(md5sum \$prof_file.new|awk '{print \$1}') != $CHECKSUM ]; then
    rm \$prof_file.new
fi
# Update config files
find /ffp/etc/mc/ -maxdepth 1 -type f -name '*.new' -exec sh -c 'mv "\$0" "\${0%.new}"' {} \;
if	[ -f /ffp/etc/mc/mc.keymap ]
then
	if	[ -L /ffp/etc/mc/mc.keymap.new ]
	then
		rm /ffp/etc/mc/mc.keymap
		mv /ffp/etc/mc/mc.keymap.new /ffp/etc/mc/mc.keymap
	fi
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
echo 'diffutils' > ${BUILDDIR}/install/slack-suggests
# Create dir for smb conf
mkdir -p ${BUILDDIR}/ffp/etc/mc/samba
makepkg ${PACKAGENAME} ${VERSION} 3
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-3.txz ${PKGDIRBACKUP}
cd
#rm -rf ${BUILDDIR}
# Revert back to standard uClibc build
#funpkg -u /mnt/HD_a2/ffp0.7arm/packages/nascentral/uClibc-0.9.33.3_git-arm-8.txz
#funpkg -u /mnt/HD_a2/ffp0.7arm/packages/nascentral/uClibc-solibs-0.9.33.3_git-arm-8.txz
#funpkg -I /mnt/HD_a2/ffp0.7arm/packages/nascentral/gcc/gettext-0.19.3-arm-1.txz
#funpkg -I /mnt/HD_a2/ffp0.7arm/packages/nascentral/gcc/libiconv-1.14-arm-2.txz
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
