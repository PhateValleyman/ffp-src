#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
unset CFLAGS
export CXXFLAGS="-march=armv5te -Wno-psabi"
export CPPFLAGS="-I/ffp/include -mno-unaligned-access"
export ARCH=arm
SOURCEDIR=/mnt/HD_a2/build
PACKAGENAME="v8"
### use http://omahaproxy.appspot.com/ to find stable v8 version
VERSION="3.23.17.23"
SOURCEURL="https://commondatastorage.googleapis.com/chromium-browser-official/${PACKAGENAME}-${VERSION}.tar.bz2"
HOMEURL="http://code.google.com/p/v8/"
#CONFIG="-Darmv7=0 -Darm_neon=0 -Darm_fpu=default -Darm_float_abi=softfp -Darm_thumb=0"
CONFIG="-Darmv7=0 -Darm_neon=0 -Darm_fpu= -Darm_float_abi=softfp -Darm_thumb="
#export GYPFLAGS="-Duse_system_icu=1 -Dv8_enable_i18n_support=1"
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
tar xvjf ${PACKAGENAME}-${VERSION}.tar.bz2
cd ${PACKAGENAME}-${VERSION}
# Apply patch
#cp -a /mnt/HD_a2//ffp0.7arm/scripts/pyload/${PACKAGENAME}.patch ${SOURCEDIR}/${PACKAGENAME}-${VERSION}/
#patch -p0 < v8.patch
# we do not need icu sources, just one icu.gyp
sed -i 's|--force|--force --trust-server-cert --non-interactive|g' Makefile
sed -i 's|\bthird_party/icu --revision |--depth=files third_party/icu --revision |' Makefile
make dependencies
# Adapt shell paths in executables to FFP prefix
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
find . -type f -iname "gyp_v8" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
### make use_system_icu=1 dependencies
build/gyp_v8 $CONFIG -Dv8_use_snapshot='false' -Dv8_no_strict_aliasing=1 -Dv8_enable_i18n_support=1 -Duse_system_icu=1 -Dconsole=readline -Dcomponent=shared_library -Dv8_target_arch=$ARCH --generator-output=out -f make
# -Dwerror=  
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
make -C out builddir=`pwd`/out/Release BUILDTYPE=Release mksnapshot.$ARCH
make -C out builddir=`pwd`/out/Release BUILDTYPE=Release
#make native snapshot=off armv7=false armfloatabi=softfp library=shared use_system_icu=1 console=readline enable_i18n_support=1
mkdir -p ${SOURCEDIR}/install ${SOURCEDIR}/ffp 
install -Dm755 out/Release/d8 ${SOURCEDIR}/ffp/bin/d8
install -Dm755 out/Release/lib.target/libv8.so ${SOURCEDIR}/ffp/lib/libv8.so
# V8 has several header files and ideally if it had its own folder in /ffp/include
# But doing it here will break all users. Ideally if they use provided pkgconfig file.
install -d ${SOURCEDIR}/ffp/include
install -Dm644 include/*.h ${SOURCEDIR}/ffp/include
wget https://raw.githubusercontent.com/archlinuxarm/PKGBUILDs/master/community/v8/v8.pc
sed -i 's|/usr|/ffp|g' v8.pc
install -d ${SOURCEDIR}/ffp/lib/pkgconfig
install -m644 ./v8.pc ${SOURCEDIR}/ffp/lib/pkgconfig
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "V8 is Google's fast and modern JavaScript engine, written in C++." >> ${SOURCEDIR}/install/DESCR
echo "V8 can run standalone, or can be embedded into any C++ application." >> ${SOURCEDIR}/install/DESCR 
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: br2:icu4c br2:readline br2:ncurses s:gcc-solibs s:uClibc-solibs" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
if [ -d ${SOURCEDIR}/ffp/share/gtk-doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/gtk-doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
#adapt executables to FFP prefix again
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/pyload/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/pyload/
fi
if [ ! -d "/ffp/funpkg/additional/pyload/" ]; then
    mkdir -p /ffp/funpkg/additional/pyload/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/pyload/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/pyload/
cd
rm -rf ${SOURCEDIR}