#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/bash"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build/build
PACKAGENAME=automake
VERSION="1.16.5"
SOURCEURL=http://ftp.gnu.org/gnu/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=http://www.gnu.org/software/automake/
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
#wget -nv ${SOURCEURL}
tar vxf /ffp/home/root/build/automake/${PACKAGENAME}-${VERSION}.tar.xz
cd ${PACKAGENAME}-${VERSION}
# Adapt scripts to FFP prefix
# Don't use it before and after configuration this time.
# First time I see it causing error and compilation will fail.
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp
colormake V=1
#There are a couple of tests that incorrectly link to the wrong version of the flex library,
#so we temporarily work around the problem. Also, using the -j4 make option speeds up the tests,
#even on systems with only one processor, due to internal delays in individual tests. To test the results, issue:
#sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
#colormake check V=1
colormake install DESTDIR=${BUILDDIR} V=1
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Automake is a tool for automatically generating Makefile.in files compliant with the GNU coding
standards. Automake requires the use of Autoconf.
License:GNU GPLv2+
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
s:perl br2:perl-modules br2:autoconf

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
# Add dependencies manually
cat >> ${BUILDDIR}/install/DEPENDS <<- EOF
perl perl-modules autoconf
EOF
cat >> ${BUILDDIR}/install/slack-required <<- EOF
perl
perl-modules
autoconf
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/gcc" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/gcc
fi
if [ ! -d "/ffp/funpkg/additional/gcc" ]; then
    mkdir -p /ffp/funpkg/additional/gcc
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/gcc/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/gcc/
cd
#rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
