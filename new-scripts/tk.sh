#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
VERSION=8.6.1
SOURCEURL=http://prdownloads.sourceforge.net/tcl/tk${VERSION}-src.tar.gz
HOMEURL=http://www.tcl.tk/
PACKAGENAME=tk
#export CPPFLAGS="-I${SOURCEDIR}/${PACKAGENAME}-${VERSION}/xlib"
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.gz
tar xvzf ${PACKAGENAME}-${VERSION}.tar.gz
mv ${PACKAGENAME}${VERSION} ${PACKAGENAME}-${VERSION}
cd ${PACKAGENAME}-${VERSION}/unix
#adapt executables to FFP prefix
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
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
./configure --prefix=/ffp --enable-shared --mandir=/ffp/share/man #--x-includes="${SOURCEDIR}/${PACKAGENAME}-${VERSION}/xlib/X11"
make
make install DESTDIR=${SOURCEDIR}
make install-private-headers DESTDIR=${SOURCEDIR}
#Remove references to the build directory and replace them with saner system-wide locations
sed -i "s|${SOURCEDIR}/${PACKAGENAME}-${VERSION}/unix|/ffp/lib|g" ${SOURCEDIR}/ffp/lib/tkConfig.sh
sed -i "s|${SOURCEDIR}/${PACKAGENAME}-${VERSION}|/ffp/include|g" ${SOURCEDIR}/ffp/lib/tkConfig.sh
#Create compatibility symbolic link
cd ${SOURCEDIR}/ffp/bin
ln -sf wish8.6 wish
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "The Tk package contains a Tcl GUI Toolkit." >> ${SOURCEDIR}/install/DESCR
echo "Tk is the standard GUI not only for Tcl, but for many other dynamic languages." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/
fi
if [ ! -d "/ffp/funpkg/additional/" ]; then
    mkdir -p /ffp/funpkg/additional/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/
cd
rm -rf ${SOURCEDIR}