#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
SOURCEURL="https://bitbucket.org/stativ/readymedia-transcode.git"
HOMEURL=http://sourceforge.net/projects/minidlna/
PACKAGENAME=readymedia-transcode
#VERSION=1.1.1_git`date "+%Y%m%d"`
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
git clone -b transcode ${SOURCEURL}
exit 0
VERSION=`cat ${SOURCEDIR}/${PACKAGENAME}/upnpglobalvars.h|grep -r "MINIDLNA_VERSION"|awk -F'"' '{print $2}'`_git`date "+%Y%m%d"`
cd ${PACKAGENAME}
# Correct bug in MiniDLNA source code for MKV video format support on Philips TV's http://sourceforge.net/projects/minidlna/forums/forum/879956/topic/5873653
sed -i 's|while( offset < end_offset )|while( offset <= end_offset )|g' upnphttp.c
# Correct pidfile and minissdp socket file paths
sed -i 's|/var/run|/ffp/var/run|g' upnpglobalvars.c
#sed -i 's|minidlna/minidlna.pid|minidlna.pid|g' upnpglobalvars.c
# Adapt shell paths in executables to FFP prefix
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
./autogen.sh
# Adapt shell paths in executables to FFP prefix again after autoconf
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
./configure --prefix=/ffp --with-db-path=/ffp/var/cache/minidlna --with-log-path=/ffp/var/log
make
make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "ReadyMedia-transcode is a personal development branch of ReadyMedia (formerly known as." >> ${SOURCEDIR}/install/DESCR
echo "MiniDLNA) created by Lukas Jirkovsky for implementing transcode capabilities in MiniDLNA." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: br2:ffmpeg2 s:libjpeg uli:flac s:libexif uli:libid3tag uli:libogg uli:libvorbis mz:sqlite br2:gettext br2:libiconv" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
# Correct minidlna name and binary path
mkdir -p ${SOURCEDIR}/ffp/bin ${SOURCEDIR}/ffp/etc
mv ${SOURCEDIR}/ffp/sbin/minidlnad ${SOURCEDIR}/ffp/bin/minidlna
rm -rf ${SOURCEDIR}/ffp/sbin
mv ${SOURCEDIR}/${PACKAGENAME}/minidlna.conf ${SOURCEDIR}/ffp/etc
rm -rf ${SOURCEDIR}/${PACKAGENAME}
# Adapt settings to ffp paths in minidlna.conf
sed -i '/#friendly_name=/c\friendly_name=MiniDLNA' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i '/#log_level=/c\log_level=general=error,artwork=error,database=error,inotify=error,scanner=error,metadata=error,http=error,ssdp=error,tivo=error' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i '/notify_interval=/c\notify_interval=60' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i 's|media_dir=/opt|media_dir=A,/mnt/HD_a2/music/\nmedia_dir=P,/mnt/HD_a2/photo/\nmedia_dir=V,/mnt/HD_a2/video/|' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i 's|/var|/ffp/var|g' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i '/#db_dir=/c\db_dir=/ffp/var/cache/minidlna' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i '/#log_dir=/c\log_dir=/ffp/var/log' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i '/#user=/c\user=minidlna' ${SOURCEDIR}/ffp/etc/minidlna.conf
sed -i '/#minissdpdsocket=/c\minissdpdsocket=/ffp/var/run/minissdpd.sock' ${SOURCEDIR}/ffp/etc/minidlna.conf
# Get start up script
mkdir -p ${SOURCEDIR}/ffp/start
cp /ffp/start/minidlna.sh ${SOURCEDIR}/ffp/start/
# Remove old minidlna settings and start script file, left by previous versions
CHECKSUM1="`md5sum ${SOURCEDIR}/ffp/etc/minidlna.conf|awk '{print $1}'`"
CHECKSUM2="`md5sum ${SOURCEDIR}/ffp/start/minidlna.sh|awk '{print $1}'`"
echo "#!/ffp/bin/sh" > ${SOURCEDIR}/install/doinst.sh
echo "" >> ${SOURCEDIR}/install/doinst.sh
echo 'if [ -f /ffp/etc/minidlna.conf.new ] && [ `md5sum /ffp/etc/minidlna.conf.new|awk '{print $1}'` = CHECKSUM1 ]; then' >> ${SOURCEDIR}/install/doinst.sh
echo "   mv /ffp/etc/minidlna.conf /ffp/etc/minidlna.conf.old" >> ${SOURCEDIR}/install/doinst.sh
echo "   mv /ffp/etc/minidlna.conf.new /ffp/etc/minidlna.conf" >> ${SOURCEDIR}/install/doinst.sh
echo "fi"  >> ${SOURCEDIR}/install/doinst.sh
echo 'if [ -f /ffp/start/minidlna.sh.new ] && [ `md5sum /ffp/start/minidlna.sh.new|awk '{print $1}'` = CHECKSUM2 ]; then' >> ${SOURCEDIR}/install/doinst.sh
echo "   mv /ffp/start/minidlna.sh.new /ffp/start/minidlna.sh" >> ${SOURCEDIR}/install/doinst.sh
echo "fi"  >> ${SOURCEDIR}/install/doinst.sh
echo 'if [ -f /ffp/start/minidlna.sh.new ] && [ `md5sum /ffp/start/minidlna.sh.new|awk '{print $1}'` != CHECKSUM2 ]; then' >> ${SOURCEDIR}/install/doinst.sh
echo "   rm /ffp/start/minidlna.sh.new" >> ${SOURCEDIR}/install/doinst.sh
echo "fi"  >> ${SOURCEDIR}/install/doinst.sh
chmod 755 ${SOURCEDIR}/install/doinst.sh
# Correct CHECKSUM and print in doinst.sh
sed -i "s|{print }|'{print $1}'|g" ${SOURCEDIR}/install/doinst.sh
sed -i 's|print |print $1|g' ${SOURCEDIR}/install/doinst.sh
sed -i "s@CHECKSUM1@$CHECKSUM1@g" ${SOURCEDIR}/install/doinst.sh
sed -i "s@CHECKSUM2@$CHECKSUM2@g" ${SOURCEDIR}/install/doinst.sh
# make ffp package
makepkg ${PACKAGENAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages
fi
if [ ! -d "/ffp/funpkg/additional" ]; then
    mkdir -p /ffp/funpkg/additional
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/
cd
rm -rf ${SOURCEDIR}