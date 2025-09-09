#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
BUILDDIR=/mnt/HD_a2/build/pip
PACKAGENAME=pip
VERSION="9.0.1"
PYTHONVERSION="python2.7"
SOURCEURL=https://pypi.io/packages/source/p/${PACKAGENAME}/${PACKAGENAME}-${VERSION}.tar.gz
HOMEURL=https://pypi.python.org/pypi/${PACKAGENAME}
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/python"
PKGDIRBACKUP="/ffp/funpkg/additional/python"
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
#wget -nv ${SOURCEURL}
tar -vxf /ffp/home/root/build/${PACKAGENAME}-${VERSION}.tar.gz
cd ${PACKAGENAME}-${VERSION}
# Adapt to FFP locations
sed -i '/^confdir/c\confdir = /ffp/etc' pip/_vendor/distlib/_backport/sysconfig.cfg
sed -i '/^datadir/c\datadir = /ffp/share' pip/_vendor/distlib/_backport/sysconfig.cfg
sed -i '/^libdir/c\libdir = /ffp/lib' pip/_vendor/distlib/_backport/sysconfig.cfg
sed -i '/^statedir/c\statedir = /ffp/var' pip/_vendor/distlib/_backport/sysconfig.cfg
# Seems like new versions of pip is using third party (requests) modules for certificates
#sed -i 's|/etc/ssl/cert.pem|/ffp/etc/ssl/cert.pem|' pip/locations.py
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
# Adapt pip.conf path to /ffp/etc/pip.conf
sed -i "s|pathlist.append('/etc')|pathlist.append('/ffp/etc')|" pip/utils/appdirs.py
# Adapt log file path to /ffp/var/log/pip.log
#sed -i 's|os.path.join(user_cache_dir(appname), "log")|"/ffp/var/log"|' pip/utils/appdirs.py
#sed -i 's|"debug.log"|"pip.log"|' pip/basecommand.py
# Change cache and data dirs
sed -i 's|~/.local/share|/ffp/share|' pip/utils/appdirs.py
sed -i 's|expanduser("~/.cache"))|expanduser("/ffp/var/cache"))|' pip/utils/appdirs.py
# Build
python2.7 setup.py install --root=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Pip is a tool for installing and managing Python packages.
License:MIT
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
ffp-buildtools git python-2.7.* setuptools tar

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
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
# Create config file for pip
mkdir -p ${BUILDDIR}/ffp/etc
touch ${BUILDDIR}/ffp/etc/pip.conf
echo "[install]" >> ${BUILDDIR}/ffp/etc/pip.conf
echo "no-cache-dir = false" >> ${BUILDDIR}/ffp/etc/pip.conf
# Create postinstall script to remove old pip.conf
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/pip.conf|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh
if  [ -f /ffp/etc/pip.conf.new ] && [ \$(md5sum /ffp/etc/pip.conf.new|awk '{print \$1}') = $CHECKSUM ]; then
   if  [ -f /ffp/etc/pip.conf ]; then
       mv /ffp/etc/pip.conf /ffp/etc/pip.conf.old
       mv /ffp/etc/pip.conf.new /ffp/etc/pip.conf
   else
       mv /ffp/etc/pip.conf.new /ffp/etc/pip.conf
   fi
fi
if  [ -f /ffp/etc/pip.conf.new ] && [ \$(md5sum /ffp/etc/pip.conf.new|awk '{print \$1}') != $CHECKSUM ]; then
    rm /ffp/etc/pip.conf.new
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Add dependencies
echo "ffp-buildtools git python-2.7.* setuptools tar" > ${BUILDDIR}/install/DEPENDS
cat > ${BUILDDIR}/install/slack-required <<- EOF
ffp-buildtools
git
python >= 2.7.13-arm-1
python < 2.8.0
setuptools
tar
EOF
makepkg ${PACKAGENAME} "${VERSION}_${PYTHONVERSION}" 1
cp -a ${PKGDIR}/${PACKAGENAME}-"${VERSION}_${PYTHONVERSION}"-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
