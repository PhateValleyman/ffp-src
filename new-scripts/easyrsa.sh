#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=easy-rsa
VERSION="3.0.1"
SOURCEURL=https://github.com/OpenVPN/${PACKAGENAME}/releases/download/${VERSION}/EasyRSA-${VERSION}.tgz
HOMEURL=https://github.com/OpenVPN/easy-rsa
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
mkdir -p ${BUILDDIR}/ffp/share/${PACKAGENAME}
wget -nv ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tgz
tar xf ${PACKAGENAME}-${VERSION}.tgz -C ${BUILDDIR}/ffp/share/${PACKAGENAME} EasyRSA-${VERSION} --strip-components=1
mv ${BUILDDIR}/ffp/share/${PACKAGENAME}/vars.example ${BUILDDIR}/ffp/share/${PACKAGENAME}/vars
#set_var EASYRSA to /ffp/share/easy-rsa by default
#sed -i '/^#set_var\ EASYRSA\t"$PWD"/c\set_var\ EASYRSA\t\t"/ffp/share/easy-rsa"' ${BUILDDIR}/ffp/share/${PACKAGENAME}/vars
# Adapt scripts to FFP prefix
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
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
easy-rsa is a CLI utility to build and manage a PKI CA. In laymen's terms,
this means to create a root certificate authority, and request and sign 
certificates, including sub-CAs and certificate revokation lists (CRL).
License:GPLv2
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:bash br2:openssl

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
# Change owner to root
chown -R root:root ${BUILDDIR}/ffp/share/${PACKAGENAME}
# Change permissions of easyrsa to 770
chmod 700 ${BUILDDIR}/ffp/share/${PACKAGENAME}
chmod 700 ${BUILDDIR}/ffp/share/${PACKAGENAME}/easyrsa
# Change dh.pem name
sed -i 's|dh.pem|dh$EASYRSA_KEY_SIZE.pem|' ${BUILDDIR}/ffp/share/${PACKAGENAME}/easyrsa
# set_var EASYRSA to /ffp/share/easy-rsa by default
sed -i 's|$PWD|/ffp/share/easy-rsa|' ${BUILDDIR}/ffp/share/${PACKAGENAME}/easyrsa
# Create symlink to /ffp/sbin
mkdir -p ${BUILDDIR}/ffp/sbin
ln -s /ffp/share/${PACKAGENAME}/easyrsa ${BUILDDIR}/ffp/sbin/easyrsa
rm ${PACKAGENAME}-${VERSION}.tgz
# Specify direct dependencies list for packages.html and slapt-get
echo "bash openssl" > ${BUILDDIR}/install/DEPENDS
echo "bash" >> ${BUILDDIR}/install/slack-required
echo "openssl" >> ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"