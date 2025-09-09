#!/ffp/bin/sh

#http://stackoverflow.com/questions/20700900/cannot-compile-qt-program-for-use-on-arm-device
#http://www.linuxfromscratch.org/blfs/view/svn/x/qt4.html
#https://github.com/archlinuxarm/PKGBUILDs/blob/master/extra/qt4/PKGBUILD
#http://qt-project.org/doc/qt-4.8/qt-embedded-install.html#step-4-adjusting-the-environment-variables
#https://groups.google.com/forum/#!topic/android-ndk/mrk5dDqWioM
# SOURCEURL=http://download.qt-project.org/archive/qt/4.7/qt-everywhere-opensource-src-4.7.3.tar.gz
# All versions since 4.7.4 has problems with accept4 system call in qtnetwork module
# due to old kernel lack of support for accept4 system call. Required minimum 2.6.36 kernel for u-Clibc 
# Zyxel's has 2.6.31. 
# https://bugreports.qt-project.org/browse/QTBUG-24914

set -e
unset CPPFLAGS
unset CXXFLAGS
unset CFLAGS
# New gcc-4.9.2 flags
CPPFLAGS="-I/ffp/include"
CXXFLAGS="-march=armv5te -I/ffp/include -O2"
CFLAGS="-march=armv5te -I/ffp/include -O2"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=qt4
VERSION="4.8.7"
SOURCEURL=http://download.qt-project.org/official_releases/qt/4.8/${VERSION}/qt-everywhere-opensource-src-${VERSION}.tar.gz
HOMEURL=http://qt-project.org
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
INSTALL_ROOT=${BUILDDIR}
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${BUILDDIR}/${PACKAGENAME}-${VERSION}/lib"
export CPPFLAGS CXXFLAGS CFLAGS PATH PKGDIR INSTALL_ROOT LD_LIBRARY_PATH
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
cd ${PACKAGENAME}-${VERSION}
make
make INSTALL_ROOT=${BUILDDIR} install
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Qt is a cross-platform application framework that is widely used for developing application software
with a graphical user interface (GUI) (in which cases Qt is classified as a widget toolkit), and
also used for developing non-GUI programs such as command-line tools and consoles for servers.
License:GPLv3, LGPL, FDL, custom
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:glib br2:gcc-solibs br2:libtiff br2:gettext br2:libiconv br2:pcre br2:uClibc-solibs br2:icu4c
br2:sqlite br2:openssl br2:mariadb br2:xorg-libs br2:zlib s:libpng s:libjpeg uli:xz-5*

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
# Remove package itself and glib2 from list of dependencies requirements
for pkgname in ${PACKAGENAME} glib2
do
	sed -i "s|\<$pkgname\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^$pkgname$/d" ${BUILDDIR}/install/slack-required
done
# Move pkg-config dir to right place
mv ${BUILDDIR}/ffp/lib/qt4/pkgconfig ${BUILDDIR}/ffp/lib
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"