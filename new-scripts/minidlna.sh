#!/ffp/bin/bash

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=minidlna
SOURCEURL="git://git.code.sf.net/p/${PACKAGENAME}/git ${PACKAGENAME}"
HOMEURL=http://sourceforge.net/projects/minidlna/
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
git clone ${SOURCEURL}
cd ${PACKAGENAME}
# (fixed in git 2016 01 27 [910b84])Temporary fix of inotify build until program author will correct it.
# https://bugs.gentoo.org/show_bug.cgi?id=132031
#sed -i '/\#include <poll.h>/a \#include <signal.h>' inotify.c
# (fixed in git 2015 09 10) Temporary fix of minidlna version until program author will correct it. 
#sed -i '/#define MINIDLNA_VERSION/c\#define MINIDLNA_VERSION "1.1.5"' upnpglobalvars.h
VERSION=$(grep -w "MINIDLNA_VERSION" upnpglobalvars.h | cut -d '"' -f2)_git$(date "+%Y%m%d")
# Update gettext version to suppress warnings about using deprecated macro-AM_PROG_MKDIR_P
sed -i "/AM_GNU_GETTEXT_VERSION/c\AM_GNU_GETTEXT_VERSION($(gettext --version | head -n 1 | awk '{print $4}'))" configure.ac
# Enable *.mod and *.tod files support
patch -p1 < ${SCRIPTDIR}/${PACKAGENAME}_mod_tod.patch
# Apply patch to enable Allshare and bookmarks on Samsung B,C,D,E series TV
#cp -a ${SCRIPTDIR}/${PACKAGENAME}-1.1.4.patch $PWD/
#patch -p1 < ${PACKAGENAME}-1.1.4.patch
### Get source code before 2013-10-23 (changes on that day, broken MiniDLNA detection on my TV)
###################git checkout 2e683354304daa0714d40d4f7fa8cf23aaffe285
#cd ..
#cp -ar ${PACKAGENAME} ${PACKAGENAME}new
#### Video playlist patch (Tested and working)
##################cp /mnt/HD_a2/ffp0.7arm/scripts/minidlna1.patch ${BUILDDIR}/${PACKAGENAME}/
##################patch -p1 < minidlna1.patch
#cp /mnt/HD_a2/ffp0.7arm/scripts/minidlna3.patch ${BUILDDIR}/${PACKAGENAME}/
#patch -p1 < minidlna3.patch
#cp /mnt/HD_a2/ffp0.7arm/scripts/minidlna2.patch ${BUILDDIR}/${PACKAGENAME}/
#patch -p1 < minidlna2.patch
### Force sorting for Panasonic TV's
###sed -i 's|"d.DATE"|"d.DISC, d.TRACK"|g' upnpsoap.c
# Correct bug in MiniDLNA source code for MKV video format support on Philips TV's http://sourceforge.net/projects/minidlna/forums/forum/879956/topic/5873653
####Solved in 1.4 version#####
#sed -i 's|while( offset < end_offset )|while( offset <= end_offset )|g' upnphttp.c
# Correct pidfile and minissdp socket file paths
sed -i 's|/var/run|/ffp/var/run|g' upnpglobalvars.c
#sed -i 's|minidlna/minidlna.pid|minidlna.pid|g' upnpglobalvars.c
# Adapt shell paths in executables to FFP prefix
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
./autogen.sh
# Adapt shell paths in executables to FFP prefix again after autoconf
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
./configure \
	--prefix=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--sbindir=/ffp/bin \
	--with-db-path=/ffp/var/cache/minidlna \
	--with-log-path=/ffp/var/log
# Enable video m3u playlists support
#meta klaida sed -i '/MUSIC_ID, _("Playlists"),/a   \	                  VIDEO_PLIST_ID, VIDEO_ID, _("Playlists"),' scanner.c
#lygtais gerai, bet nera playlistu video sekcijoj, jie muzikos kataloge  sed -i '/VIDEO_ID, _("Folders"),/a     \	                  VIDEO_PLIST_ID, VIDEO_ID, _("Playlists"),' scanner.c
#sed -i 's|MUSIC_PLIST_ID, MUSIC_ID|MUSIC_PLIST_ID, VIDEO_ID|g' scanner.c #sitas tipo veike anksciau
#pabandyti sita su antru variantu kur viskas gerai sed -i 's|MUSIC_PLIST_ID|VIDEO_PLIST_ID|g' playlist.c
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

MiniDLNA (aka ReadyDLNA) is server software with the aim of being fully compliant with DLNA, 
UPnP-AV clients. 
License: GNU GPLv2
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
# Remove unused docs if any exists
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct minidlna daemon name to old format and copy config file to final place
mkdir -p ${BUILDDIR}/ffp/etc
mv ${BUILDDIR}/ffp/bin/minidlnad ${BUILDDIR}/ffp/bin/minidlna
mv ${BUILDDIR}/${PACKAGENAME}/${PACKAGENAME}.conf ${BUILDDIR}/ffp/etc
# Install man pages
install -Dm644 ${PACKAGENAME}/minidlna.conf.5 ${BUILDDIR}/ffp/share/man/man5/minidlna.conf.5
install -Dm644 ${PACKAGENAME}/minidlnad.8 ${BUILDDIR}/ffp/share/man/man8/minidlna.8
rm -rf ${BUILDDIR}/${PACKAGENAME}
# Adapt settings to ffp paths in minidlna.conf
sed -i '/#friendly_name=/c\friendly_name=MiniDLNA' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i '/#log_level=/c\log_level=general=error,artwork=error,database=error,inotify=error,scanner=error,metadata=error,http=error,ssdp=error,tivo=error' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i '/notify_interval=/c\notify_interval=60' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i 's|media_dir=/opt|media_dir=A,/mnt/HD_a2/music/\nmedia_dir=P,/mnt/HD_a2/photo/\nmedia_dir=V,/mnt/HD_a2/video/|' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i 's|/var|/ffp/var|g' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i '/#db_dir=/c\db_dir=/ffp/var/cache/minidlna' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i '/#log_dir=/c\log_dir=/ffp/var/log' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i '/#user=/c\user=minidlna' ${BUILDDIR}/ffp/etc/minidlna.conf
sed -i '/#minissdpdsocket=/c\minissdpdsocket=/ffp/var/run/minissdpd.sock' ${BUILDDIR}/ffp/etc/minidlna.conf
# Get start up script
mkdir -p ${BUILDDIR}/ffp/start
cp /ffp/start/minidlna.sh ${BUILDDIR}/ffp/start/
# Remove old minidlna settings and start script file, left by previous versions
CHECKSUMCONF=$(md5sum ${BUILDDIR}/ffp/etc/minidlna.conf|awk '{print $1}')
CHECKSUMSCRIPT=$(md5sum ${BUILDDIR}/ffp/start/minidlna.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

DATE=\$(date "+%Y%m%d_%H%M%S")

if	[ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') = $CHECKSUMSCRIPT ]; then
	if	[ -f /ffp/start/${PACKAGENAME}.sh ]; then
		mv /ffp/start/${PACKAGENAME}.sh /ffp/start/${PACKAGENAME}.sh.old\${DATE}
		chmod 644 /ffp/start/${PACKAGENAME}.sh.old\${DATE}
		mv /ffp/start/${PACKAGENAME}.sh.new /ffp/start/${PACKAGENAME}.sh
	else
		mv /ffp/start/${PACKAGENAME}.sh.new /ffp/start/${PACKAGENAME}.sh
	fi
fi
if	[ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') != $CHECKSUMSCRIPT ]; then
	rm /ffp/start/${PACKAGENAME}.sh.new
fi
if	[ -f /ffp/etc/${PACKAGENAME}.conf.new ] && [ \$(md5sum /ffp/etc/${PACKAGENAME}.conf.new|awk '{print \$1}') = $CHECKSUMCONF ]; then
	if	[ -f /ffp/etc/${PACKAGENAME}.conf ]; then
		mv /ffp/etc/${PACKAGENAME}.conf /ffp/etc/${PACKAGENAME}.conf.old\${DATE}
		mv /ffp/etc/${PACKAGENAME}.conf.new /ffp/etc/${PACKAGENAME}.conf
	else
		mv /ffp/etc/${PACKAGENAME}.conf.new /ffp/etc/${PACKAGENAME}.conf
	fi
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Make an FFP package
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"