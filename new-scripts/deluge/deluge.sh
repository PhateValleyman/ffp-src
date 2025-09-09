#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=deluge
GITURL=git://deluge-torrent.org/deluge.git
GITBRANCH=1.3-stable
HOMEURL=http://deluge-torrent.org/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}"
PKGDIRBACKUP="/ffp/funpkg/additional/${PACKAGENAME}"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
git clone -q -b ${GITBRANCH} ${GITURL} ${PACKAGENAME}
################
#git --work-tree=${PACKAGENAME} --git-dir=${PACKAGENAME}/.git reset --hard 41ac46c7feb97bec2dc5068503fdd2f42d55b7a5
cd ${PACKAGENAME}
# Get rid of suffix .dev0 when building deluge
sed -i '/^tag_build = -dev/d' setup.cfg
# Get version number
REVISION=$(git rev-parse --short HEAD)
VERSION=$(grep 'version = "' setup.py | cut -d '"' -f2)_git${REVISION}
#VERSION=$(cat setup.py | grep 'version =' | awk -F'"' '{print $2}'| xargs)_git$(date "+%Y%m%d")
# Adapt source code scripts to FFP prefix
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
# Adapt config to FFP and Zyxel's NAS
sed -i 's|deluge.common.get_default_download_dir()|"/mnt/HD_a2/video"|' deluge/core/preferencesmanager.py
sed -i 's|"allow_remote": False|"allow_remote": True|' deluge/core/preferencesmanager.py
sed -i 's|/usr/share/GeoIP/GeoIP.dat|/ffp/share/GeoIP/GeoIP.dat|' deluge/core/preferencesmanager.py
# Build
#python setup.py build
python setup.py install --root=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Deluge is a full-featured  BitTorrent client for Linux, OS X, Unix and Windows. It uses  libtorrent
in its backend and features multiple user-interfaces including: GTK+, web and console. It has been
designed using the client server model with a daemon process that handles all the bittorrent activity.
The Deluge daemon is able to run on headless machines with the user-interfaces being able to
connect remotely from any platform.
License: GNU GPLv3
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
br2:boost br2:bzip2 br2:db5 br2:expat br2:ffp-buildtools br2:freetype br2:gcc-solibs br2:gdbm br2:geoip
br2:gettext br2:giflib br2:icu4c br2:intltool br2:libffi br2:libiconv br2:libjpeg br2:libpng br2:libtiff
br2:libtorrent br2:libwebp br2:ncurses br2:openssl br2:pip br2:python-2.7.* br2:readline br2:setuptools
br2:sqlite br2:uClibc-solibs br2:zlib

Important!
After instaling FFP dependancies you need to install additional python modules for deluge.
Run from command line:
pip install cryptography pyOpenSSL service-identity twisted pyxdg chardet setproctitle mako pillow
Active internet connection is required for pip install command.
It will take some time to complete this operation.

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Install licence
mkdir -p "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}"
install -Dm644 LICENSE "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}/LICENSE"
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}*
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/${PACKAGENAME}d.sh ${BUILDDIR}/ffp/start/
# Create postinstall script to remove old start-up script
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/${PACKAGENAME}d.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

echo -e "\e[1;31;25mIMPORTANT NOTICE: Don't forget to install required python modules for deluge:\e[0m"
echo -e "\e[1;34;25mpip install cryptography service-identity twisted pyopenssl pyxdg chardet setproctitle mako pillow\e[0m"

if [ -f /ffp/start/${PACKAGENAME}d.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}d.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
   mv /ffp/start/${PACKAGENAME}d.sh.new /ffp/start/${PACKAGENAME}d.sh
fi
if [ -f /ffp/start/${PACKAGENAME}d.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}d.sh.new|awk '{print \$1}') != $CHECKSUM ]; then
   rm /ffp/start/${PACKAGENAME}d.sh.new
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
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
# Correct issue with deluge dev versions (unnecessary after using hack-Get rid of suffix .dev0 when building deluge)
#sed -i 's|split(".")]|split(".") if value.isdigit()]|' ${BUILDDIR}/ffp/lib/python2.7/site-packages/deluge/core/core.py
#sed -i 's|split(".")]|split(".") if x.isdigit()]|' ${BUILDDIR}/ffp/lib/python2.7/site-packages/deluge/common.py
# Add dependencies
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DEPENDS  << EOF
ffp-buildtools python setuptools pip boost icu4c libffi libtorrent geoip ncurses readline intltool
gettext libiconv expat gcc-solibs uClibc-solibs gdbm sqlite db5 openssl bzip2 zlib libtiff libwebp
freetype giflib libjpeg libpng
EOF
cat > ${BUILDDIR}/install/slack-required << EOF
ffp-buildtools
python
setuptools
pip
boost
icu4c
libffi
libtorrent
geoip
ncurses
readline
intltool
gettext
libiconv
expat
gcc-solibs
uClibc-solibs
gdbm
sqlite
db5
openssl
bzip2
zlib
libtiff
libwebp
freetype
giflib
libjpeg
libpng
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"