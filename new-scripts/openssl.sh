#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=openssl
VERSION="1.0.2d"
SOURCEURL=http://openssl.org/source/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=https://www.openssl.org/
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
wget -nv ${SOURCEURL}
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
# Don't use zlib-dynamic configure option, because static openssl lib will use shared zlib via dlopen (libdl)
# This will lead to segfault of static builds, which uses static openssl lib and uClibc-ng > 1.0.17
./config --prefix=/ffp \
		--openssldir=/ffp/etc/ssl \
		--libdir=lib \
		no-idea \
		no-rc5 \
		shared
make depend
make
make test
make INSTALL_PREFIX=${BUILDDIR} MANDIR=/ffp/share/man install
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured,
and Open Source toolkit implementing the Transport Layer Security (TLS) and Secure Sockets Layer (SSL)
protocols as well as a full-strength general purpose cryptography library. 
License: custom BSD style
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
openssh-7.1p1-arm-2 uClibc-solibs zlib

EOF
# Direct dependencies list for packages.html and slapt-get
cat > ${BUILDDIR}/install/DEPENDS << EOF
openssh-7.1p1-arm-2 uClibc-solibs zlib
EOF
cat > ${BUILDDIR}/install/slack-required << EOF
openssh = 7.1p1-arm-1
uClibc-solibs
zlib
EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unused docs
if	[ -d ${BUILDDIR}/ffp/share/doc ]; then
	rm -rf ${BUILDDIR}/ffp/share/doc
fi
# No api docs
rm -rf ${BUILDDIR}/ffp/share/man/man3
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
# Get ca-bundle for new ssl module
wget -nv http://curl.haxx.se/ca/cacert.pem -O ${BUILDDIR}/ffp/etc/ssl/cert.pem
# Create postinstall script to remove old cert.pem and openssl config file
# Also automatic install of hard dependency-openssh is included 
CHECKSUMCERT=$(md5sum ${BUILDDIR}/ffp/etc/ssl/cert.pem|awk '{print $1}')
CHECKSUMCNF=$(md5sum ${BUILDDIR}/ffp/etc/ssl/openssl.cnf|awk '{print $1}')
CHECKSUMCHASH=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_hash|awk '{print $1}')
CHECKSUMCISSUER=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_issuer|awk '{print $1}')
CHECKSUMCINFO=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_info|awk '{print $1}')
CHECKSUMCASH=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/CA.sh|awk '{print $1}')
CHECKSUMCNAME=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_name|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

if	[ -f /ffp/etc/ssl/cert.pem.new ] && [ \$(md5sum /ffp/etc/ssl/cert.pem.new|awk '{print \$1}') = $CHECKSUMCERT ]; then
	mv /ffp/etc/ssl/cert.pem.new /ffp/etc/ssl/cert.pem
fi
if	[ -f /ffp/etc/ssl/cert.pem.new ] && [ \$(md5sum /ffp/etc/ssl/cert.pem.new|awk '{print \$1}') != $CHECKSUMCERT ]; then
	rm /ffp/etc/ssl/cert.pem.new
fi
if	[ -f /ffp/etc/ssl/openssl.cnf.new ] && [ \$(md5sum /ffp/etc/ssl/openssl.cnf.new|awk '{print \$1}') = $CHECKSUMCNF ]; then
	mv /ffp/etc/ssl/openssl.cnf.new /ffp/etc/ssl/openssl.cnf
fi
if	[ -f /ffp/etc/ssl/openssl.cnf.new ] && [ \$(md5sum /ffp/etc/ssl/openssl.cnf.new|awk '{print \$1}') != $CHECKSUMCNF ]; then
	rm /ffp/etc/ssl/openssl.cnf.new
fi
if	[ -f /ffp/etc/ssl/misc/c_hash.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_hash.new|awk '{print \$1}') = $CHECKSUMCHASH ]; then
	mv /ffp/etc/ssl/misc/c_hash.new /ffp/etc/ssl/misc/c_hash
fi
if	[ -f /ffp/etc/ssl/misc/c_hash.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_hash.new|awk '{print \$1}') != $CHECKSUMCHASH ]; then
	rm /ffp/etc/ssl/misc/c_hash.new
fi
if	[ -f /ffp/etc/ssl/misc/c_issuer.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_issuer.new|awk '{print \$1}') = $CHECKSUMCISSUER ]; then
	mv /ffp/etc/ssl/misc/c_issuer.new /ffp/etc/ssl/misc/c_issuer
fi
if	[ -f /ffp/etc/ssl/misc/c_issuer.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_issuer.new|awk '{print \$1}') != $CHECKSUMCISSUER ]; then
	rm /ffp/etc/ssl/misc/c_issuer.new
fi
if	[ -f /ffp/etc/ssl/misc/c_info.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_info.new|awk '{print \$1}') = $CHECKSUMCINFO ]; then
	mv /ffp/etc/ssl/misc/c_info.new /ffp/etc/ssl/misc/c_info
fi
if	[ -f /ffp/etc/ssl/misc/c_info.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_info.new|awk '{print \$1}') != $CHECKSUMCINFO ]; then
	rm /ffp/etc/ssl/misc/c_info.new
fi
if	[ -f /ffp/etc/ssl/misc/CA.sh.new ] && [ \$(md5sum /ffp/etc/ssl/misc/CA.sh.new|awk '{print \$1}') = $CHECKSUMCASH ]; then
	mv /ffp/etc/ssl/misc/CA.sh.new /ffp/etc/ssl/misc/CA.sh
fi
if	[ -f /ffp/etc/ssl/misc/CA.sh.new ] && [ \$(md5sum /ffp/etc/ssl/misc/CA.sh.new|awk '{print \$1}') != $CHECKSUMCASH ]; then
	rm /ffp/etc/ssl/misc/CA.sh.new
fi
if	[ -f /ffp/etc/ssl/misc/c_name.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_name.new|awk '{print \$1}') = $CHECKSUMCNAME ]; then
	mv /ffp/etc/ssl/misc/c_name.new /ffp/etc/ssl/misc/c_name
fi
if	[ -f /ffp/etc/ssl/misc/c_name.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_name.new|awk '{print \$1}') != $CHECKSUMCNAME ]; then
	rm /ffp/etc/ssl/misc/c_name.new
fi

EOF
cat >> ${BUILDDIR}/install/doinst.sh <<'EOF'
# Install hard dependency: openssh deeply depends on openssl version which was used at openssh compile time.
# Updating only openssl will brake ssh daemon start. 
deps="br2:openssh-7.1p1-arm-2.txz"
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

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"