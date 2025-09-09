#!/ffp/bin/bash

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=dejavu-fonts-ttf
VERSION="2.37"
SOURCEURL=http://sourceforge.net/projects/dejavu/files/dejavu/${VERSION}/${PACKAGENAME}-${VERSION}.tar.bz2
HOMEURL=https://dejavu-fonts.github.io/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/ffmpeg3"
PKGDIRBACKUP="/ffp/funpkg/additional/ffmpeg3"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @"${STARTTIME}" +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
wget -nv ${SOURCEURL}
tar xf "${SOURCEURL##*/}"
cd ${PACKAGENAME}-${VERSION}
# Adapt config files to FFP prefix
for conf_files in ${BUILDDIR}/${PACKAGENAME}-${VERSION}/fontconfig/*.conf
do
	sed -i "s|../fonts.dtd|fonts.dtd|" "$conf_files"
	sed -i "s|/etc/fonts|/ffp/etc/fonts|" "$conf_files"
done
# Place them in apprioriate dir, where we can update them and make symlinks for fontconfig
mkdir -p ${BUILDDIR}/ffp/share/fontconfig/conf.avail
mkdir -p /ffp/share/fontconfig/conf.avail
cp -a fontconfig/*.conf /ffp/share/fontconfig/conf.avail
mv fontconfig/*.conf ${BUILDDIR}/ffp/share/fontconfig/conf.avail
mkdir -p ${BUILDDIR}/ffp/etc/fonts/conf.d
ln -s /ffp/share/fontconfig/conf.avail/*-dejavu-*.conf ${BUILDDIR}/ffp/etc/fonts/conf.d/
rm /ffp/share/fontconfig/conf.avail/*-dejavu-*.conf
mkdir -p ${BUILDDIR}/ffp/share/fonts
mv ttf/ ${BUILDDIR}/ffp/share/fonts
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

The DejaVu fonts are a font family based on the Vera Fonts. Its purpose is to provide a wider range
of characters while maintaining the original look and feel through the process of collaborative development. 
License: custom (https://dejavu-fonts.github.io/License.html)
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Install licence
mkdir -p "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}"
install -Dm644 LICENSE "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}/LICENSE"
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Add fontconfig package as depedency
echo "fontconfig" > ${BUILDDIR}/install/DEPENDS
echo "fontconfig" >  ${BUILDDIR}/install/slack-required
# Correct ownership of downloaded files
chown -R root:root ${BUILDDIR}/ffp
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$((ENDTIME-STARTTIME))
echo "End point:$(date -d @"${ENDTIME}" +%F\ %T)"
echo "Compile duration: $((DIFF / 3600 )) hours $((DIFF / 60 % 60)) minutes and $((DIFF % 60)) seconds"