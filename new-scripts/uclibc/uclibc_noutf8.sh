#!/ffp/bin/sh

#http://lists.uclibc.org/pipermail/uclibc/2011-February/044822.html
#http://ftp.osuosl.org/pub/manulix/scripts/build-scripts/PATCHCMDS/
#http://lists.uclibc.org/pipermail/uclibc-cvs/2011-September/029861.html
#http://stackoverflow.com/questions/602912/how-do-you-echo-a-4-digit-unicode-character-in-bash
#http://repo.or.cz/w/glibc.git/blob_plain/1b188a651ec0af5dad0f368afdc6fdfbfd8dfce2:/localedata/charmaps/KOI8-RU
#http://www.tldp.org/HOWTO/Danish-HOWTO-5.html
set -e
export SHELL="/ffp/bin/sh"
export CONFIG_SHELL="/ffp/bin/sh"
export PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
SOURCEDIR=/mnt/HD_a2/build
BUILDDIR=/mnt/HD_a2/build/tmp
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
GITBRANCH=0.9.33
GITURL=git://uclibc.org/uClibc.git
HOMEURL=http://www.uclibc.org/
PACKAGENAME=uClibc
PACKAGENAME1=uClibc-solibs
VERSION=$GITBRANCH
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${SOURCEDIR}
git clone -q -b ${GITBRANCH} ${GITURL} ${PACKAGENAME}
cd ${PACKAGENAME}
EXTRAVERSION=$(grep '^EXTRAVERSION' Rules.mak | awk -F':=' '{print $2}'| sed 's|-|_|')
# uClibc doesn't support expand $ORIGIN in ELF files RPATH, thus openjdk fails to find native libs
# One way is to patch, another use of ld.so.conf and specify custom additional paths for libs search
# I choosed patch way. Patch should be revised again with future uClic updates.
#http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-core/uclibc/uclibc-git/orign_path.patch?h=denzil
for patches in ${SCRIPTDIR}/${PACKAGENAME}-*.patch; do
        patch -p1 < $patches
done
#Add wcsftime() from master branch
wget 'https://git.busybox.net/uClibc/patch/?id=bc23c6440d34d85c8e6bb04656beb233bba47cb8' -O 1.patch
patch -p1 < 1.patch
wget 'https://git.busybox.net/uClibc/patch/?id=b36422960466777495933ed1eb50befd1c34e9a9' -O 2.patch
patch -p1 < 2.patch
# Remove -Wdeclaration-after-statement to suppress this warning: ISO C90 forbids mixed declarations and code
sed -i 's| -Wdeclaration-after-statement||' Rules.mak
# Correct ldconfig dir path
sed -i 's|usr/lib|lib|g' utils/ldconfig.c
# Copy build config to sourcedir
cp -a ${SCRIPTDIR}/.config_noutf8 $PWD/.config
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
# Confirm silently old config
make silentoldconfig
# Make uClibc headers and libraries, then utils
make
make utils
# Install shared libs and make uClibc-solibs package first
make PREFIX=${BUILDDIR} install_runtime
cp -av lib/*.so* ${BUILDDIR}/ffp/lib/
mkdir -p ${BUILDDIR}/install
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME1}:
uClibc (aka µClibc/pronounced yew-see-lib-see) is a C library for developing embedded Linux systems.
It is much smaller than the GNU C Library, but nearly all applications supported by glibc also work
perfectly with uClibc.
NOTE:This package contains the shared libraries only.
License(s): GNU LGPL
Version:${VERSION}${EXTRAVERSION}
Homepage:http://www.uclibc.org/

Depends on these packages:
br2:uClibc mz:kernel_headers-2.6.31.8

IMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.
Other devices with kernel different from 2.6.31.8 are only partly compatible.
This release doesn't has UTF-8 locales support.

EOF
echo ${HOMEURL} >> ${BUILDDIR}/install/HOMEPAGE
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
echo -e "\e[1;34;42mIMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.\e[0m"
echo -e "\e[1;31;21mOther devices with kernel different from 2.6.31.8 are only partly compatible.\e[0m"
echo -e "\e[1;31;21mThis release doesn't has UTF-8 locales support.\e[0m"
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Create uClibc-solibs package
makepkg ${PACKAGENAME1} ${VERSION}${EXTRAVERSION} 9
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
fi
if [ ! -d "/ffp/funpkg/additional/${PACKAGENAME}/" ]; then
    mkdir -p /ffp/funpkg/additional/${PACKAGENAME}/
fi
cp /tmp/${PACKAGENAME1}-${VERSION}${EXTRAVERSION}-arm-9.txz /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
mv /tmp/${PACKAGENAME1}-${VERSION}${EXTRAVERSION}-arm-9.txz /ffp/funpkg/additional/${PACKAGENAME}/
cd ${SOURCEDIR}/${PACKAGENAME}
# Install and make uClibc package
make PREFIX=${BUILDDIR} install
make PREFIX=${BUILDDIR} install_utils
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Correct description and required dependencies for main uClibc package
sed -i 's|uClibc-solibs|uClibc|' ${BUILDDIR}/install/DESCR
sed -i 's|br2:uClibc|br2:uClibc-solibs|' ${BUILDDIR}/install/DESCR
sed -i '/^NOTE:/d' ${BUILDDIR}/install/DESCR
# Create main uClibc package
makepkg ${PACKAGENAME} ${VERSION}${EXTRAVERSION} 9
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
fi
if [ ! -d "/ffp/funpkg/additional/${PACKAGENAME}/" ]; then
    mkdir -p /ffp/funpkg/additional/${PACKAGENAME}/
fi
cp /tmp/${PACKAGENAME}-${VERSION}${EXTRAVERSION}-arm-9.txz /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
mv /tmp/${PACKAGENAME}-${VERSION}${EXTRAVERSION}-arm-9.txz /ffp/funpkg/additional/${PACKAGENAME}/
cd
rm -rf ${SOURCEDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"