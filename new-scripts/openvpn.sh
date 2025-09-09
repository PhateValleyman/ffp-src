#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=openvpn
VERSION="2.3.13"
SOURCEURL=https://swupdate.openvpn.org/community/releases/${PACKAGENAME}-${VERSION}.tar.xz
HOMEURL=https://openvpn.net/
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
wget -nv ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.tar.xz
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
./configure \
		--build=$GNU_BUILD \
		--host=$GNU_HOST \
		--prefix=/ffp \
		--sbindir=/ffp/bin \
		--disable-plugin-auth-pam
# Adapt executables to FFP prefix after configuration
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
make
#make check # Test passes OK. Disabled for quicker build 
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
An easy-to-use, robust, and highly configurable VPN (Virtual Private Network) solution.
License:GPLv2 with OpenSSL exception
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
mz:zyxel_modules-2.6.31.8, if you have Zyxel NSA3** series, otherwise look for the tun.ko module,
which supports your kernel.  
mz:zyxel_modules-\$(uname -r) br2:kmod br2:easy-rsa br2:lzo br2:openssl br2:uClibc-solibs br2:sudo
s:busybox-netutils

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Correct owner of contrib and examples dir
chown -R root:root $PWD/{sample,contrib} 
# Copy config examples
mkdir -p ${BUILDDIR}/ffp/share/openvpn/examples
for dir in sample/sample-{config-files,keys,plugins,scripts}
do
	cp -a "$dir" ${BUILDDIR}/ffp/share/openvpn/examples/
done
# Install community contributed scripts
cp -a contrib ${BUILDDIR}/ffp/share/openvpn/
# Copy configs for server and clients to final location
mkdir -p ${BUILDDIR}/ffp/etc/openvpn/server
mkdir -p ${BUILDDIR}/ffp/etc/openvpn/client
cp -a sample/sample-config-files/server.conf ${BUILDDIR}/ffp/etc/openvpn/server/
cp -a sample/sample-config-files/client.conf ${BUILDDIR}/ffp/etc/openvpn/client/
# Adjust client.conf settings
sed -i 's|^;tls-auth|tls-auth|' ${BUILDDIR}/ffp/etc/openvpn/client/client.conf
# Adjust server.conf settings
sed -i 's|^;tls-auth|tls-auth|' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
sed -i 's|^;topology subnet|topology subnet|' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
sed -i 's|cipher AES-256-CBC|cipher AES-128-CBC|' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
sed -i $'/^;push "redirect-gateway*/i\;push "redirect-gateway def1"' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
sed -i $'/^;push "redirect-gateway def1"/i\push "route 0.0.0.0 0.0.0.0"' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
sed -i $'/^push "route 0.0.0.0 0.0.0.0"/i\push "route-metric 999"' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
# Only for pre 2.4 versions-enable lzo compresion (it was enabled by default in 2.3.10 and disabled since 2.3.13)
# In the future 2.4 version we will use lz4-v2 compression and will push it to clients. Then leave comp-lzo disabled and enable lz4-v2
sed -i 's|;comp-lzo|comp-lzo|' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
# Bug? in 2.3.13 version-Options error: --explicit-exit-notify cannot be used with --mode server
# Disabling for now. Will check in later versions.
sed -i 's|explicit-exit-notify 1|;explicit-exit-notify 1|' ${BUILDDIR}/ffp/etc/openvpn/server/server.conf
cat >> ${BUILDDIR}/ffp/etc/openvpn/server/server.conf <<- 'EOF'

# Add VPN clients to arp table for default network interface.
# This will let for VPN clients reach multiple machines on the server's network (LAN).
client-connect client-connect.sh
client-disconnect client-disconnect.sh
EOF
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
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
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/openvpn-{server,client}.sh ${BUILDDIR}/ffp/start/
# Create postinstall script to remove old start-up script
CHECKSUM_SERVER=$(md5sum ${BUILDDIR}/ffp/start/openvpn-server.sh|awk '{print $1}')
CHECKSUM_CLIENT=$(md5sum ${BUILDDIR}/ffp/start/openvpn-client.sh|awk '{print $1}')
CHECKSUM_SERVER_CONF=$(md5sum ${BUILDDIR}/ffp/etc/openvpn/server/server.conf|awk '{print $1}')
CHECKSUM_CLIENT_CONF=$(md5sum ${BUILDDIR}/ffp/etc/openvpn/client/client.conf|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

DATE=\$(date "+%Y%m%d_%H%M%S")

# Replace server and client services start files by new versions
if  [ -f /ffp/start/openvpn-server.sh.new ] && [ \$(md5sum /ffp/start/openvpn-server.sh.new|awk '{print \$1}') = $CHECKSUM_SERVER ]; then
   if  [ -f /ffp/start/openvpn-server.sh ]; then
       mv /ffp/start/openvpn-server.sh /ffp/start/openvpn-server.sh.old\${DATE}
       chmod 644 /ffp/start/openvpn-server.sh.old\${DATE}
       mv /ffp/start/openvpn-server.sh.new /ffp/start/openvpn-server.sh
   else
       mv /ffp/start/openvpn-server.sh.new /ffp/start/openvpn-server.sh
   fi
fi
if  [ -f /ffp/start/openvpn-server.sh.new ] && [ \$(md5sum /ffp/start/openvpn-server.sh.new|awk '{print \$1}') != $CHECKSUM_SERVER ]; then
    rm /ffp/start/openvpn-server.sh.new
fi
if  [ -f /ffp/start/openvpn-client.sh.new ] && [ \$(md5sum /ffp/start/openvpn-client.sh.new|awk '{print \$1}') = $CHECKSUM_CLIENT ]; then
   if  [ -f /ffp/start/openvpn-client.sh ]; then
       mv /ffp/start/openvpn-client.sh /ffp/start/openvpn-client.sh.old\${DATE}
       chmod 644 /ffp/start/openvpn-client.sh.old\${DATE}
       mv /ffp/start/openvpn-client.sh.new /ffp/start/openvpn-client.sh
   else
       mv /ffp/start/openvpn-client.sh.new /ffp/start/openvpn-client.sh
   fi
fi
if  [ -f /ffp/start/openvpn-client.sh.new ] && [ \$(md5sum /ffp/start/openvpn-client.sh.new|awk '{print \$1}') != $CHECKSUM_CLIENT ]; then
    rm /ffp/start/openvpn-client.sh.new
fi

# Replace server and client config files by new versions
if	[ -f /ffp/etc/openvpn/server/server.conf.new ] && [ \$(md5sum /ffp/etc/openvpn/server/server.conf.new|awk '{print \$1}') = $CHECKSUM_SERVER_CONF ]; then
	if	[ -f /ffp/etc/openvpn/server/server.conf ]; then
		mv /ffp/etc/openvpn/server/server.conf /ffp/etc/openvpn/server/server.conf.old\${DATE}
		mv /ffp/etc/openvpn/server/server.conf.new /ffp/etc/openvpn/server/server.conf
	else
		mv /ffp/etc/openvpn/server/server.conf.new /ffp/etc/openvpn/server/server.conf
	fi
fi
if	[ -f /ffp/etc/openvpn/client/client.conf.new ] && [ \$(md5sum /ffp/etc/openvpn/client/client.conf.new|awk '{print \$1}') = $CHECKSUM_CLIENT_CONF ]; then
	if	[ -f /ffp/etc/openvpn/client/client.conf ]; then
		mv /ffp/etc/openvpn/client/client.conf /ffp/etc/openvpn/client/client.conf.old\${DATE}
		mv /ffp/etc/openvpn/client/client.conf.new /ffp/etc/openvpn/client/client.conf
	else
		mv /ffp/etc/openvpn/client/client.conf.new /ffp/etc/openvpn/client/client.conf
	fi
fi

EOF
cat >> ${BUILDDIR}/install/doinst.sh <<- 'EOF'
# Post-install time to adjust server.conf settings to host
gateway="$(ip route show | awk '/^default/ {print$3}')"
default_nic="$(ip route show | awk '/^default/ {print$5}')"
#local_ip="$(ip -f inet -o addr show $default_nic | cut -d ' ' -f7 | cut -d '/' -f1)"
local_subnet="$(ip -f inet -o addr show $default_nic | cut -d ' ' -f9 | cut -d '.' -f1,2,3)"
sed -i "s|^server 10.8.0.0 255.255.255.0|server $local_subnet.224 255.255.255.240|" /ffp/etc/openvpn/server/server.conf
sed -i "s|^;push \"route 192.168.10.0|push \"route $local_subnet.0|" /ffp/etc/openvpn/server/server.conf
sed -i "s|^;push \"dhcp-option DNS 208.67.222.222\"|;push \"dhcp-option DNS $gateway\"|" /ffp/etc/openvpn/server/server.conf

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Create client connect and disconnect scripts
cat > ${BUILDDIR}/ffp/etc/openvpn/server/client-connect.sh << 'EOF'
#! /ffp/bin/sh
default_nic="$(/bin/ip route show | grep -w 'default' | awk 'NR==1 {print $5}')"
/ffp/bin/sudo /ffp/sbin/arp -i "$default_nic" -Ds "$ifconfig_pool_remote_ip" "$default_nic" pub
/ffp/bin/sudo /bin/ip route add "$ifconfig_pool_remote_ip"/32 dev "$dev"
EOF
chmod 700 ${BUILDDIR}/ffp/etc/openvpn/server/client-connect.sh
cat > ${BUILDDIR}/ffp/etc/openvpn/server/client-disconnect.sh << 'EOF'
#! /ffp/bin/sh
default_nic="$(/bin/ip route show | grep -w 'default' | awk 'NR==1 {print $5}')"
/ffp/bin/sudo /ffp/sbin/arp -i "$default_nic" -d "$ifconfig_pool_remote_ip"
/ffp/bin/sudo /bin/ip route del "$ifconfig_pool_remote_ip"/32 dev "$dev"
EOF
chmod 700 ${BUILDDIR}/ffp/etc/openvpn/server/client-disconnect.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
if [ -d ${BUILDDIR}/ffp/install ]; then
   mv ${BUILDDIR}/ffp/install/* ${BUILDDIR}/install
   rm -rf ${BUILDDIR}/ffp/install
fi
# Remove duplicate gcc and uclibc and in some cases package itself dependencies requirements
for pkgname in gcc uClibc ${PACKAGENAME}; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
# Add additional dependencies including easy-rsa for generating certs and keys
sed -i '1 s|$| kmod sudo easy-rsa busybox-netutils zyxel_modules|' ${BUILDDIR}/install/DEPENDS
cat >> ${BUILDDIR}/install/slack-required <<- EOF
busybox-netutils
easy-rsa
kmod
sudo
zyxel_modules
EOF
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"