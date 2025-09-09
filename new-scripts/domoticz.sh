#!/ffp/bin/sh

#updated sites with uwsiteloader
#slacker -UuiA br2:{gcc,gcc-solibs,gmp,mpfr,mpc,autoconf,automake,binutils,make,m4,pkg-config,libtool,check,dejagnu,expect,tcl,help2man,flex,texinfo,bison,intltool,libiconv,gettext,ncurses,perl-modules,uClibc,uClibc-solibs,findutils,patchutils} s:{perl-5.*,db5,gawk,diffutils,gzip,bzip2,coreutils,grep,patch} mz:kernel_headers uli:zlib
#slacker -uiA br2:{boost,icu4c,curl,rtmpdump} mz:{libusb,libusb_compat,subversion,sqlite,} uli:{apr,apr-util}
#slacker -uiA br2:{mc,glib,pcre,libffi}

set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=domoticz
VERSION="3.8153"
SOURCEURL=https://github.com/${PACKAGENAME}/${PACKAGENAME}/archive/${VERSION}.tar.gz
HOMEURL=http://www.domoticz.com
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @"${STARTTIME}" +%F\ %T)"
### Create new swap space
if	[ ! -d /mnt/HD_a2/.zyxel ]
then
	mkdir -p /mnt/HD_a2/.zyxel
fi
swap_dir="$(readlink -f /mnt/HD_a2/.zyxel)"
swap_file="$swap_dir/$(hostname)_swapfile"
if	! grep "$swap_file" /proc/swaps >/dev/null
then
	if	[ -f "$swap_file" ]
	then
		chmod 600 "$swap_file"
		mkswap "$swap_file"
		swapon "$swap_file"
	else
		# Create 1 GB swap file
		dd if=/dev/zero of="$swap_file" bs=1M count=1024
		chmod 600 "$swap_file"
		mkswap "$swap_file"
		swapon "$swap_file"
	fi
fi
echo "Current swapfile(s) in use is:"
swapon -s
# Create build, and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
#Get domoticz source code from svn repository:
wget -nv ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.gz
tar xf ${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}-${VERSION}
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
# Fix version info
sed -i "/^#define APPVERSION/c\#define APPVERSION ${VERSION}" appversion.default
# Fix paths
sed -i 's|/opt/domoticz|/ffp/opt/domoticz|g' main/domoticz.cpp
# We are using external Lua libs from now (following action is not required anymore)
#sed -i '/#define LUA_ROOT/s:/usr/local/:/ffp/:' lua/src/luaconf.h
#
# Prevent using backtrace lib on release builds (DHAVE_EXECINFO_H=0)
# Otherwise specify linking to backtrace lib, if debug build is used 
# -DCMAKE_EXE_LINKER_FLAGS_RELEASE=-lubacktrace
cmake . \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX=/ffp/opt/domoticz \
	-DUSE_BUILTIN_LUA=OFF \
	-DUSE_BUILTIN_MQTT=OFF \
	-DUSE_BUILTIN_SQLITE=OFF \
	-DUSE_BUILTIN_ZLIB=OFF \
	-DUSE_STATIC_BOOST=OFF \
	-DUSE_STATIC_LIBSTDCXX=OFF \
	-DUSE_STATIC_OPENZWAVE=OFF \
	-DHAVE_EXECINFO_H=0 \
	-DUSE_PYTHON=OFF
make
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME}:
Domoticz is a very light weight Home Automation System that lets you monitor and configure various
devices like: Lights, Switches, various sensors/meters like Temperature, Rain, Wind, UV, Electra,
Gas, Water and much more. Notifications/Alerts can be sent to any mobile device.
License: GPLv3
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
boost curl libusb libusb-compat lua mosquitto openssl openzwave python-2.7.* sqlite gcc-solibs
uClibc-solibs zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove not used scripts
rm ${BUILDDIR}/ffp/opt/domoticz/updatedomo
rm ${BUILDDIR}/ffp/opt/domoticz/scripts/download_update.sh
rm ${BUILDDIR}/ffp/opt/domoticz/scripts/update_domoticz
rm ${BUILDDIR}/ffp/opt/domoticz/scripts/_domoticz_main.bat
# Remove unused docs
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
# Adapt scripts to FFP prefix again before making package
sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' ${BUILDDIR}/ffp/opt/domoticz/scripts/_domoticz_main
mv ${BUILDDIR}/ffp/opt/domoticz/scripts/_domoticz_main ${BUILDDIR}/ffp/opt/domoticz/scripts/domoticz_main
chmod 775 ${BUILDDIR}/ffp/opt/domoticz/scripts/domoticz_main
# Consider build logrotate package and adjust the domoticz logrotate script for it (later?)
# Deleting it for now
rm -rf ${BUILDDIR}/ffp/opt/domoticz/scripts/logrotate
# Adjust restart script
cat > ${BUILDDIR}/ffp/opt/domoticz/scripts/restart_domoticz << EOF
#!/ffp/bin/sh

if	[ -f /ffp/start/domoticz.sh ]
then
	sh /ffp/start/domoticz.sh restart
fi
EOF
chmod 755 ${BUILDDIR}/ffp/opt/domoticz/scripts/restart_domoticz
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
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/${PACKAGENAME}.sh ${BUILDDIR}/ffp/start/
# Create postinstall script to remove old start-up script
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/domoticz.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

# Replace current start script if newer exists
if  [ -f /ffp/start/domoticz.sh.new ] && [ \$(md5sum /ffp/start/domoticz.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
   if  [ -f /ffp/start/domoticz.sh ]; then
       mv /ffp/start/domoticz.sh /ffp/start/domoticz.sh.old
       chmod 644 /ffp/start/domoticz.sh.old
       mv /ffp/start/domoticz.sh.new /ffp/start/domoticz.sh
   else
       mv /ffp/start/domoticz.sh.new /ffp/start/domoticz.sh
   fi
fi
if  [ -f /ffp/start/domoticz.sh.new ] && [ \$(md5sum /ffp/start/domoticz.sh.new|awk '{print \$1}') != $CHECKSUM ]; then
    rm /ffp/start/domoticz.sh.new
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s| \<${PACKAGENAME}\>||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
sed -i "s| \<libusb_compat\>||" ${BUILDDIR}/install/DEPENDS
sed -i "/^libusb_compat$/d" ${BUILDDIR}/install/slack-required
# Add additional dependencies
sed -i '1 s|$| python-2.7.*|' ${BUILDDIR}/install/DEPENDS
cat >> ${BUILDDIR}/install/slack-required <<- EOF
python >= 2.7.13-arm-1
python < 2.8.0
EOF
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$((ENDTIME-STARTTIME))
echo "End point:$(date -d @"${ENDTIME}" +%F\ %T)"
echo "Compile duration: $((DIFF / 3600 )) hours $((DIFF / 60 % 60)) minutes and $((DIFF % 60)) seconds"