#!/ffp/bin/bash

# Databases:
# http://dev.maxmind.com/geoip/legacy/geolite/
# http://dev.maxmind.com/geoip/legacy/downloadable/
# geoipupdate:
# http://dev.maxmind.com/geoip/geoipupdate/
# Testing:
# geoiplookup www.google.com; geoiplookup6 www.google.com; geoiplookup 8.8.8.8; geoiplookup6 2001:4860:4860::8888
# cd /ffp/share/GeoIP; geoipupdate
set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
unset CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=geoip
SOURCEURL=https://github.com/maxmind/geoip-api-c
GITNAME="${SOURCEURL##*/}"
HOMEURL=http://dev.maxmind.com/geoip/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/deluge"
PKGDIRBACKUP="/ffp/funpkg/additional/deluge"
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
git clone ${SOURCEURL}
cd ${GITNAME}
REVISION="$(git rev-parse --short HEAD)"
VERSION="$(git describe --abbrev=0 --tags|cut -f2 -d'v')_git${REVISION}"
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
autoreconf -fi
#adapt scripts to FFP prefix again after autoreconf
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
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

This packages contains several sources combined:
1. GeoIP Legacy C library and utilities, that enables for user to find geographical and network
information of an IP address or hostname.
2. geoipupdate utility-GeoIP update program performs automatic updates of GeoIP2 and GeoIP
legacy binary databases.
3. Maxmind legacy GeoLiteCountry and GeoLiteCountryv6 databases.
License(s): GeoIP Legacy C library-LGPLv2.1, geoipupdate utility-GPLv2,
            GeoLite databases-Creative Commons Attribution-ShareAlike 4.0 International License:
            https://creativecommons.org/licenses/by-sa/4.0/
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Install licence
mkdir -p "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}"
install -Dm644 COPYING "${BUILDDIR}/ffp/share/licenses/${PACKAGENAME}/COPYING"
cd ${BUILDDIR}
rm -rf ${BUILDDIR:?}/${GITNAME}
SOURCEURL1=https://github.com/maxmind/geoipupdate
GITNAME1="${SOURCEURL1##*/}"
cd ${BUILDDIR}
git clone ${SOURCEURL1}
cd ${GITNAME1}
# Add user and databases id's to conf
sed -i '/^ProductIds GeoLite2-Country GeoLite2-City/ s/^#*/# /' conf/GeoIP.conf.default
sed -i '/^# ProductIds 506 517 533/c\ProductIds 506 GeoLite-Legacy-IPv6-Country' conf/GeoIP.conf.default
sed -i 's|/usr/local/share/GeoIP|/ffp/share/GeoIP|' conf/GeoIP.conf.default
cat >> conf/GeoIP.conf.default <<- EOF

# You can include one or more of the following ProductIds to update them:
# GeoLite2-City - GeoLite 2 City
# GeoLite2-Country - GeoLite2 Country
# GeoLite-Legacy-IPv6-City - GeoLite Legacy IPv6 City
# GeoLite-Legacy-IPv6-Country - GeoLite Legacy IPv6 Country
# 506 - GeoLite Legacy Country
# 517 - GeoLite Legacy ASN
# 533 - GeoLite Legacy City
# NOTE: geoipupdate doesn't support GeoIPASNumv6.dat updating.
EOF
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
autoreconf -fi
# Adapt scripts to FFP prefix again after autoreconf
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
	--build="$GNU_BUILD" \
	--host="$GNU_HOST" \
	--prefix=/ffp
make
if	[ ! -d ${BUILDDIR}/ffp/etc ]
then
	mkdir ${BUILDDIR}/ffp/etc
fi
make install DESTDIR=${BUILDDIR}
# Install licence
mkdir -p "${BUILDDIR}/ffp/share/licenses/${GITNAME1}"
install -Dm644 LICENSE "${BUILDDIR}/ffp/share/licenses/${GITNAME1}/LICENSE"
cd ${BUILDDIR}
rm -rf ${BUILDDIR:?}/${GITNAME1}
# Remove unused docs if present
if [ -d ${BUILDDIR}/ffp/share/doc ]
then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
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
# Create directory for databases and get the latest ones
if [ ! -d "${BUILDDIR}/ffp/share/GeoIP" ]
then
    mkdir -p ${BUILDDIR}/ffp/share/GeoIP
fi
cd ${BUILDDIR}/ffp/share/GeoIP
wget -nv http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget -nv http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz
#wget -nv http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
#wget -nv http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
#wget -nv http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
#wget -nv http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz
gunzip GeoIP.dat.gz GeoIPv6.dat.gz #GeoLiteCity.dat.gz GeoLiteCityv6.dat.gz GeoIPASNum.dat.gz GeoIPASNumv6.dat.gz
# Rename them to files names used by geoipupdate, so it will not duplicate databases.
# Remark: geoipupdate doesn't support GeoIPASNumv6.dat updating.
mv GeoIP.dat GeoLiteCountry.dat
#mv GeoIPASNum.dat GeoLiteASNum.dat
# Make compatability links for databases. Only  GeoIPv6.dat is compatible.
# These symlinks required for GeoIP C library and utilities to function correctly, because geoipupdate utility
# downloads databases with different names.
ln -sf GeoLiteCountry.dat GeoIP.dat
#ln -sf GeoLiteCity.dat GeoIPCity.dat
#ln -sf GeoLiteCityv6.dat GeoIPCityv6.dat
#ln -sf GeoLiteASNum.dat GeoIPASNum.dat
# Install licence
mkdir -p "${BUILDDIR}/ffp/share/licenses/GeoLite/databases"
echo 'https://creativecommons.org/licenses/by-sa/4.0/' > "${BUILDDIR}/ffp/share/licenses/GeoLite/databases/LICENSE"
cd ${BUILDDIR}
# Remove old Geoip settings left by previous versions
CHECKSUMCONF="$(md5sum ${BUILDDIR}/ffp/etc/GeoIP.conf|awk '{print $1}')"
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

DATE=\$(date "+%Y%m%d_%H%M%S")

if	[ -f /ffp/etc/GeoIP.conf.new ] && [ \$(md5sum /ffp/etc/GeoIP.conf.new|awk '{print \$1}') = $CHECKSUMCONF ]
then
	if	[ -f /ffp/etc/GeoIP.conf ]
	then
		mv /ffp/etc/GeoIP.conf /ffp/etc/GeoIP.conf.old\${DATE}
		mv /ffp/etc/GeoIP.conf.new /ffp/etc/GeoIP.conf
	else
		mv /ffp/etc/GeoIP.conf.new /ffp/etc/GeoIP.conf
	fi
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} "${VERSION}" 1
cp -a ${PKGDIR}/"${PACKAGENAME}-${VERSION}"-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$((ENDTIME-STARTTIME))
echo "End point:$(date -d @"${ENDTIME}" +%F\ %T)"
echo "Compile duration: $((DIFF / 3600 )) hours $((DIFF / 60 % 60)) minutes and $((DIFF % 60)) seconds"