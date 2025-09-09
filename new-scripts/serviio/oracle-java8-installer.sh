#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=oracle-java8-installer
SCRIPT_FULLPATH=/mnt/HD_a2/ffp0.7arm/useful_scripts/oraclejava
VERSION="$(grep '^#\ Version:' /i-data/7cf371c4/ffp0.7arm/useful_scripts/oraclejava | cut -d ' ' -f3)"
HOMEURL="http://forum.nas-central.org/viewtopic.php?f=249&t=18267"
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/serviio"
PKGDIRBACKUP="/ffp/funpkg/additional/serviio"
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
mkdir -p ffp/bin
cp -a ${SCRIPT_FULLPATH} ffp/bin/
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
This package contains helper script to install Oracle Java 8 Java(TM) SE Embedded Runtime Environment (JRE).
After installing it, just run from command line: oraclejava install or oraclejava upgrade. Also helper script
can be used to install/upgrade Oracle Java JRE 8 from ejdk release archive files:
    oraclejava install /path/to/dir/ejdk-8u*-linux-arm-sflt.tar.gz
or
    oraclejava upgrade /path/to/dir/ejdk-8u*-linux-arm-sflt.tar.gz
License:GPLv2+
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
br2:bash br2:wget br2:findutils br2:ncurses s:coreutils s:dialog

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
# Add dependencies
echo "bash wget findutils ncurses coreutils dialog" > ${BUILDDIR}/install/DEPENDS
cat > ${BUILDDIR}/install/slack-required << EOF
bash
wget
findutils
ncurses
coreutils
dialog
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"