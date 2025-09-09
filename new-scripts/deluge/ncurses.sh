#!/ffp/bin/sh

set -e
unset TERMINFO
export SHELL="/ffp/bin/sh"
export CPPFLAGS="$CPPFLAGS -D_XOPEN_SOURCE_EXTENDED"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR="/mnt/HD_a2/build"
PACKAGENAME=ncurses
VERSION=5.9_20140927
SOURCEURL=ftp://invisible-island.net/ncurses/current/ncurses-5.9-20140927.tgz
HOMEURL=http://invisible-island.net/ncurses/ncurses.html
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
wget -nv ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tgz
tar -xzf ${PACKAGENAME}-${VERSION}.tgz --transform=s"|`echo ${SOURCEURL}|awk -F'/' '{print $6}'|cut -f1,2 -d'.'`|${PACKAGENAME}-${VERSION}|"
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
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
./configure --prefix=/ffp \
			--build=$GNU_BUILD \
			--host=$GNU_HOST \
			--with-shared \
			--with-cxx-shared \
			--enable-warnings \
			--without-ada \
			--without-debug \
			--with-pkg-config \
			--enable-pc-files \
			--enable-widec \
			--without-tests \
			--disable-overwrite
#./configure --prefix=/ffp --with-shared --with-cxx-shared --enable-warnings --without-ada --without-debug --with-pkg-config --enable-pc-files --enable-rpath --enable-widec --enable-overwrite --without-tests #--with-cxx-shared --with-pthread --disable-overwrite
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
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME}:
Ncurses (new curses) is a programming library that provides an API which allows the programmer to 
write text-based user interfaces in a terminal-independent manner. It is a toolkit for developing
GUI-like application software that runs under a terminal emulator. It also optimizes screen changes,
in order to reduce the latency experienced when using remote shells.
License:MIT
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:uClibc br2:uClibc-solibs

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Fool packages looking to link to non-wide-character ncurses libraries
cd ${BUILDDIR}/ffp/lib
for lib in ncurses ncurses++ form panel menu; do
  ln -s lib${lib}w.a lib${lib}.a
  ln -s lib${lib}w.so lib${lib}.so
  ln -s lib${lib}w.so.5 lib${lib}.so.5
  ln -s lib${lib}w.so.5.9 lib${lib}.so.5.9
done
cd pkgconfig
for lib in ncurses ncurses++ form panel menu; do
  ln -s ${lib}w.pc ${lib}.pc
done
cd ${BUILDDIR}/ffp/bin
ln -s ncursesw5-config ncurses5-config
# Create symlinks for ncurses headers in /ffp/include
cd ${BUILDDIR}/ffp/include
for file in ncursesw/* ; do
    ln -s $file .
done
cd ${BUILDDIR}
# Remove unneccesary docs
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
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
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/deluge" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/deluge
fi
if [ ! -d "/ffp/funpkg/additional/deluge" ]; then
    mkdir -p /ffp/funpkg/additional/deluge
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/deluge/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/deluge/
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"