#!/ffp/bin/bash -e
A=$(ls icu4c-*-src.t*)
P=$(echo ${A%-src*} | tr _ .)
. ./funpkg.inc
_begin

cd icu/source

CFLAGS="$CFLAGS -DU_USING_ICU_NAMESPACE=0"

CFLAGS="$CFLAGS" \
CXXFLAGS="$CFLAGS" \
LDFLAGS="$FFP_LDFLAGS" \
./runConfigureICU \
	Linux \
	--prefix=/ffp \
	--enable-static \
	--with-data-packaging=archive

make
make DESTDIR=$D install

_doc ../*license* ../readme.html

_descr
_makepkg


