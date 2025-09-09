#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
PERL_CPANM_HOME=/temp
PERL_MM_OPT="INSTALLDIRS=vendor"
PERL_MB_OPT="--installdirs vendor"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=cpanminus
GITURL=https://github.com/miyagawa/cpanminus
HOMEURL=http://cpanmin.us/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/perl"
PKGDIRBACKUP="/ffp/funpkg/additional/perl"
export PATH PKGDIR PERL_CPANM_HOME PERL_MM_OPT PERL_MB_OPT
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
git clone -q ${GITURL}
cd ${PACKAGENAME}
REVISION=$(git rev-parse --short HEAD)
# not good sed -i 's|my$homedir=$ENV{HOME}|my$homedir=/tmp|' cpanm
perl Makefile.PL PREFIX=/ffp
VERSION=$(grep '^VERSION =' Makefile | cut -d ' ' -f3)_git${REVISION}
make
make test
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
cpanminus is a handy script to get, unpack, build and install modules from CPAN in easy way.
CPAN-Comprehensive Perl Archive Network is repository of software for the perl programming language.
License: Perl artistic or GPLv1+
Version: ${VERSION}
Homepage: ${HOMEURL}
Depends on these packages:
ffp-buildtools git perl tar

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}
# Remove unnecessary docs dir
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Remove perllocal.pod and .packlist files-this is not local module install
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "perllocal.pod" -exec rm -f {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname ".packlist" -exec rm -f {} \;
fi
#Delete dir, which is side effect of installing (not required any more since 5.24.0 version?)
#if [ -d /ffp/lib/perl5/site_perl/5.14.2/arm-linux-thread-multi-64int/.meta ]; then
#    rm -rf /ffp/lib/perl5/site_perl/5.14.2/arm-linux-thread-multi-64int/.meta
#fi
# Add dependencies
echo "ffp-buildtools git perl tar" > ${BUILDDIR}/install/DEPENDS
cat > ${BUILDDIR}/install/slack-required <<- EOF
ffp-buildtools
git
perl
tar
EOF
makepkg ${PACKAGENAME} ${VERSION}_perl 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}_perl-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"