#!/ffp/bin/sh

########################################################
#CAUTION!!! Uninstall temporary perl-modules ffp package 
#(slacker -r perl-modules) to build this one correctly with dependencies.
#########################################################################
set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
SOURCEURL=http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/XML-Parser-2.41.tar.gz
HOMEURL=http://search.cpan.org/~toddr/XML-Parser/Parser.pm
PACKAGENAME=xmlparser
NAME=XML-Parser
VERSION=`echo ${SOURCEURL}|awk -F'-' '{print $3}'|cut -f1,2 -d'.'`
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
export PERL_MM_OPT="INSTALLDIRS=vendor DESTDIR=${SOURCEDIR}"
export PERL_MB_OPT="--installdirs vendor --destdir ${SOURCEDIR}"
export PERL5LIB="${SOURCEDIR}/ffp/lib/perl5/vendor_perl/5.14.2"
cd ${SOURCEDIR}
/ffp/bin/cpanm XML::Parser
#wget ${SOURCEURL}
#tar xvzf ${NAME}-${VERSION}.tar.gz
#cd ${NAME}-${VERSION}
#perl Makefile.PL PREFIX=/ffp
#make
#make test
#make install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of XML::Parser:" >> ${SOURCEDIR}/install/DESCR
echo "The XML::Parser is a perl module for parsing XML documents, perl extension" >> ${SOURCEDIR}/install/DESCR
echo "interface for James Clark's expat." >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: br2:expat s:perl-5.14.2" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "###########################################################################" >> ${SOURCEDIR}/install/DESCR
echo "NOTE!!! This package includes also perl dependent modules for XML::Parser :" >> ${SOURCEDIR}/install/DESCR
echo "URI-1.60 LWP-MediaTypes-6.02 Encode-Locale-1.03 HTTP-Date-6.02 IO-HTML-1.00" >> ${SOURCEDIR}/install/DESCR
echo "HTTP-Message-6.06 File-Listing-6.04 HTTP-Negotiate-6.01 HTML-Tagset-3.20 HTML-Parser-3.71" >> ${SOURCEDIR}/install/DESCR
echo "HTTP-Daemon-6.01 Net-HTTP-6.06 HTTP-Cookies-6.01 WWW-RobotRules-6.02 libwww-perl-6.05" >> ${SOURCEDIR}/install/DESCR
echo "#########################################################################################" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} >> ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${NAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Remove perllocal.pod and .packlist files-this is not local module install
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "perllocal.pod" -exec rm -f {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname ".packlist" -exec rm -f {} \;
fi
#Delete dir, which is side effect of installing
if [ -d ${SOURCEDIR}/ffp/lib/perl5/site_perl/5.14.2/arm-linux-thread-multi-64int/.meta ]; then
    rm -rf ${SOURCEDIR}/ffp/lib/perl5/site_perl/5.14.2/arm-linux-thread-multi-64int/.meta
fi
makepkg ${PACKAGENAME} ${VERSION}_perl 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/perl" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/perl
fi
if [ ! -d "/ffp/funpkg/additional/perl" ]; then
    mkdir -p /ffp/funpkg/additional/perl
fi
cp /tmp/${PACKAGENAME}-${VERSION}_perl-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/perl/
mv /tmp/${PACKAGENAME}-${VERSION}_perl-arm-1.txz /ffp/funpkg/additional/perl/
cd
rm -rf ${SOURCEDIR}