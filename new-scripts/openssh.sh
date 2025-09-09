#!/ffp/bin/sh

# https://www.ualberta.ca/CNS/RESEARCH/LinuxClusters/pka-putty.html
# How to convert Putty generated public key to OpenSSH format and import to authorized_keys 
#ssh-keygen -if /mnt/HD_a2/public/nsa310.pub >> /root/.ssh/authorized_keys
#chmod -R 600 /root/.ssh 
#rm /mnt/HD_a2/public/nsa310.pub
set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build/openssh
PACKAGENAME=openssh
VERSION="9.0p1"
SOURCEURL=http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=http://www.openssh.com/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if	[ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
#wget -nv ${SOURCEURL}
cp -R /i-data/md1/COMPILER/finish/${PACKAGENAME}-${VERSION}.tar.gz ${BUILDDIR}
tar xf ${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}-${VERSION}
# Adapt for ffp shell test scripts
for testfile in $(egrep -lr '/bin/sh' regress | xargs);  do
	sed -i "s|/bin/sh|/ffp/bin/sh|" $testfile
done
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
	--prefix=/ffp \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--sysconfdir=/ffp/etc/ssh \
	--with-md5-passwords \
	--with-privsep-path=/ffp/var/lib/sshd \
	--with-default-path=$PATH \
	--with-mantype=man \
	--with-ssl-engine \
	--with-pid-dir=/ffp/var/run
colormake
# Client statvfs test fails?
#make tests || true
colormake DESTDIR=${BUILDDIR} install
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
OpenSSH is a FREE version of the SSH connectivity tools that technical users of the Internet rely on.
Users of telnet, rlogin, and ftp may not realize that their password is transmitted across the Internet
unencrypted, but it is. OpenSSH encrypts all traffic (including passwords) to effectively eliminate
eavesdropping, connection hijacking, and other attacks. Additionally, OpenSSH provides secure tunneling
capabilities and several authentication methods, and supports all SSH protocol versions. 
License: BSD
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:gcc-solibs br2:uClibc-solibs br2:openssl-1.0.2d-arm-1 uli:zlib

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unused docs
if	[ -d ${BUILDDIR}/ffp/share/doc ]; then
	rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if	[ -d ${BUILDDIR}/ffp/lib ]; then
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
# Root login is disabled in new releases of openssh by default.
# Enable root login for compatibility with older openssh releases
sed -i '/#PermitRootLogin/c\PermitRootLogin yes' ${BUILDDIR}/ffp/etc/ssh/sshd_config
# Copy  start-up script
mkdir -p ${BUILDDIR}/ffp/start
cp -a /ffp/start/sshd.sh ${BUILDDIR}/ffp/start/
# Create postinstall script to remove old start-up script and replace old configs
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/start/sshd.sh|awk '{print $1}')
SSHCHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/ssh/ssh_config|awk '{print $1}')
SSHDCHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/ssh/sshd_config|awk '{print $1}')
MODCHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/ssh/moduli|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

DATE=\$(date "+%Y%m%d_%H%M%S")

if	[ -f /ffp/start/sshd.sh.new ] && [ \$(md5sum /ffp/start/sshd.sh.new|awk '{print \$1}') = $CHECKSUM ]; then
	if	[ -f /ffp/start/sshd.sh ]; then
		mv /ffp/start/sshd.sh /ffp/start/sshd.sh.old\${DATE}
		chmod 644 /ffp/start/sshd.sh.old\${DATE}
		mv /ffp/start/sshd.sh.new /ffp/start/sshd.sh
	else
		mv /ffp/start/sshd.sh.new /ffp/start/sshd.sh
	fi
fi
if	[ -f /ffp/start/sshd.sh.new ] && [ \$(md5sum /ffp/start/sshd.sh.new|awk '{print \$1}') != $CHECKSUM ]; then
	rm /ffp/start/sshd.sh.new
fi
if	[ -f /ffp/etc/ssh/ssh_config.new ] && [ \$(md5sum /ffp/etc/ssh/ssh_config.new|awk '{print \$1}') = $SSHCHECKSUM ]; then
	if	[ -f /ffp/etc/ssh/ssh_config ]; then
		mv /ffp/etc/ssh/ssh_config /ffp/etc/ssh/ssh_config.old\${DATE}
		mv /ffp/etc/ssh/ssh_config.new /ffp/etc/ssh/ssh_config
	else
		mv /ffp/etc/ssh/ssh_config.new /ffp/etc/ssh/ssh_config
	fi
fi
if	[ -f /ffp/etc/ssh/sshd_config.new ] && [ \$(md5sum /ffp/etc/ssh/sshd_config.new|awk '{print \$1}') = $SSHDCHECKSUM ]; then
	if	[ -f /ffp/etc/ssh/sshd_config ]; then
		mv /ffp/etc/ssh/sshd_config /ffp/etc/ssh/sshd_config.old\${DATE}
		mv /ffp/etc/ssh/sshd_config.new /ffp/etc/ssh/sshd_config
	else
		mv /ffp/etc/ssh/sshd_config.new /ffp/etc/ssh/sshd_config
	fi
fi
if	[ -f /ffp/etc/ssh/moduli.new ] && [ \$(md5sum /ffp/etc/ssh/moduli.new|awk '{print \$1}') = $MODCHECKSUM ]; then
	if	[ -f /ffp/etc/ssh/moduli ]; then
		mv /ffp/etc/ssh/moduli /ffp/etc/ssh/moduli.old\${DATE}
		mv /ffp/etc/ssh/moduli.new /ffp/etc/ssh/moduli
	else
		mv /ffp/etc/ssh/moduli.new /ffp/etc/ssh/moduli
	fi
fi

EOF
cat >> ${BUILDDIR}/install/doinst.sh <<'EOF'
# Install hard dependency: openssh deeply depends on openssl version which was used at openssh compile time.
# Updating openssh only (without openssl) will brake ssh daemon start. 
deps="br2:openssl-1.0.2d-arm-1.txz"
echo -e "\e[1;32;20mResolving dependent packages:\e[0m"
for dep in $deps; do
	# Set repo url
	repo=$(echo $dep | awk -F':' '{print $1}')
	pkgfile=$(echo $dep | awk -F':' '{print $2}')
	pkgname=$(echo "$pkgfile" | awk -F'.txz' '{print $1}')
	case "$repo" in
		s)
			repourl=http://www.inreto.de/ffp/0.7/arm/packages
			;;
		uli)
			repourl=http://funplug.wolf-u.li/0.7/arm/packages
			;;
		kylek)
			repourl=http://kylek.is-a-geek.org:31337/files/ffp/0.7-arm
			;;
		memiks)
			repourl=http://ffp.memiks.fr/pkg
			;;
		br2)
			repourl=http://downloads.zyxel.nas-central.org/Users/barmalej2/ffp/0.7/arm/packages
			;;
		ar)
			repourl=http://downloads.zyxel.nas-central.org/Users/ariek/ffp/0.7-arm-packages
			;;
		mz)
			repourl=http://downloads.zyxel.nas-central.org/Users/Mijzelf/FFP-Stick/packages/0.7/arm
			;;
		*)
			echo -e "\e[1;31;20mUnknown repository specified for dependent package:$pkgfile\e[0m"
			echo -e "\e[1;31;20mFailed to install-$dep...\e[0m"
			continue
	esac
	# Update checksums files for repos
	repochecksumfile=/ffp/funpkg/cache/"$repo"/CHECKSUMS.md5
	if	[ ! -f "$repochecksumfile" ] || [ -n "$(find "$repochecksumfile" -mtime +1)" ]; then 
		if	[ ! -d /ffp/funpkg/cache/"$repo" ]; then
			mkdir -p /ffp/funpkg/cache/"$repo"
		fi
		wget -q "$repourl"/CHECKSUMS.md5 -O /ffp/funpkg/cache/"$repo"/CHECKSUMS.md5
		if	[ "$?" != "0" ]; then
			echo -e "\e[1;31;20mFailed to update {$repo:} repository cache!\e[0m"
			continue
		fi
	fi
	# Find package full path in repository
	if	grep -w "$pkgfile" "$repochecksumfile" >> /dev/null; then
		pkgrepopath="$(grep -w "$pkgfile" "$repochecksumfile" | awk '{print $2}')"
		pkgchecksum="$(grep -w "$pkgfile" "$repochecksumfile" | awk '{print $1}')"
	else
		echo -e "\e[1;31;20mDependent package:$pkgfile was not found in {$repo:} repository!\e[0m"
		continue
	fi
	# Check if package is installed
	if	[ -f /ffp/funpkg/installed/"$pkgname" ]; then
		echo -e "\e[1;32;20mDependent package:$pkgfile is already installed. [ OK ]\e[0m"
		continue
	else
		echo -e "\e[1;33;20m$pkgfile is not installed. [ QUEUED ]\e[0m"
		cd /ffp/funpkg/cache/"$repo"
		if	[ -f "$pkgfile" ] && [ "$(md5sum "$pkgfile"|awk '{print $1}')" = "$pkgchecksum" ]; then
			echo "Requested $pkgfile was found in cache-/ffp/funpkg/cache/$repo"
			funpkg -u "$pkgfile"
			if	[ -f /ffp/funpkg/installed/"$pkgname" ]; then
				echo -e "\e[1;32;20mDependent package:$pkgfile installed successfully! [ OK ]\e[0m"
				continue
			else
				if	[ "$(funpkg -u "$pkgfile")" = "$pkgname: Not installed" ] >> /dev/null; then
					funpkg -i "$pkgfile"
					if	[ -f /ffp/funpkg/installed/"$pkgname" ]; then
						echo -e "\e[1;32;20mDependent package:$pkgfile installed successfully! [ OK ]\e[0m"
						continue
					else
						echo -e "\e[1;31;20mFailed to install dependent package:$pkgfile !!!\e[0m"
						continue
					fi
				else
					echo -e "\e[1;31;20mFailed to install dependent package:$pkgfile !!!\e[0m"
					continue
				fi
			fi
		else
			echo "Requested $pkgfile was not found in cache-/ffp/funpkg/cache/$repo"
			echo "Downloading $pkgfile ..."
			wget -nv "$repourl"/"$pkgrepopath" -O "$pkgfile"
			if	[ "$?" != "0" ]; then
				echo "\e[1;31;20mFailed to download $pkgfile !\e[0m"
				continue
			fi
			if	[ -f "$pkgfile" ] && [ "$(md5sum "$pkgfile"|awk '{print $1}')" = "$pkgchecksum" ];then
				funpkg -u "$pkgfile"
				if	[ -f /ffp/funpkg/installed/"$pkgname" ]; then
					echo -e "\e[1;32;20mDependent package:$pkgfile installed successfully! [ OK ]\e[0m"
					continue
				else
					if	[ "$(funpkg -u "$pkgfile")" = "$pkgname: Not installed" ] >> /dev/null; then
						funpkg -i "$pkgfile"
						if	[ -f /ffp/funpkg/installed/"$pkgname" ]; then
							echo -e "\e[1;32;20mDependent package:$pkgfile installed successfully! [ OK ]\e[0m"
							continue
						else
							echo -e "\e[1;31;20mFailed to install dependent package:$pkgfile !!!\e[0m"
							continue
						fi
					else
						echo -e "\e[1;31;20mFailed to install dependent package:$pkgfile !!!\e[0m"
						continue
					fi
				fi
			else
				echo -e "\e[1;31;20mFailed to install dependent package:$pkgfile !!!\e[0m"
			fi
		fi
	fi
done
# Generate host keys
# For private keys default permissions are 600
# Public keys are not relevant, so 644 is enough	
for key in /ffp/etc/ssh/{ssh_host_rsa_key,ssh_host_dsa_key,ssh_host_ecdsa_key,ssh_host_ed25519_key}
do
	if	[ ! -f $key ]
	then
		/ffp/bin/ssh-keygen -A
	fi
done
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
if	[ -d ${BUILDDIR}/ffp/install ]; then
	mv ${BUILDDIR}/ffp/install/* ${BUILDDIR}/install
	rm -rf ${BUILDDIR}/ffp/install
fi
# Remove duplicate gcc and uclibc and in some cases package itself dependencies requirements
for pkgname in gcc uClibc ${PACKAGENAME}; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
# Set exact openssl version requirement
sed -i "s|openssl|openssl-1.0.2d-arm-1|" ${BUILDDIR}/install/DEPENDS
sed -i "s|openssl|openssl = 1.0.2d-arm-1|" ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
