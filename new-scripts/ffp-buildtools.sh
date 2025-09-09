#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=ffp-buildtools
VERSION="0.7"
HOMEURL=https://forum.nas-central.org/viewforum.php?f=249
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
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

The ffp-buildtools is a meta-package. It doesn't contains any files. Just triggers slap-get package 
manager to install packages necessary for getting, configuring and compiling source code for ffp. 
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
cat > ${BUILDDIR}/install/DEPENDS << EOF
autoconf automake binutils bison bzip2 check cmake coreutils dejagnu diffutils expect findutils flex gawk
gcc gcc-solibs gettext git gmp grep gzip help2man intltool kernel-headers libiconv libtool m4 make mpc
mpfr ncurses patch patchutils perl perl-modules pkg-config tar tcl texinfo uClibc uClibc-solibs wget zlib
EOF

cat > ${BUILDDIR}/install/slack-required << EOF
autoconf
automake
binutils
bison
bzip2
check
cmake
coreutils
dejagnu
diffutils
expect
findutils
flex
gawk
gcc
gcc-solibs
gettext
git
gmp
grep
gzip
help2man
intltool
kernel-headers
libiconv
libtool
m4
make
mpc
mpfr
ncurses
patch
patchutils
perl
perl-modules
pkg-config
tar
tcl
texinfo
uClibc
uClibc-solibs
wget
zlib
EOF
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"