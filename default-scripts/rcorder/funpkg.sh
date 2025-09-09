#!/ffp/bin/bash -e
. ./funpkg.inc
_begin

mv pkgsrc/pkgtools/rcorder/files     rcorder
mv pkgsrc/pkgtools/libnbcompat/files rcorder/libnbcompat

cd rcorder/libnbcompat
patch -p1 -i $X/libnbcompat-Makefile.patch

$CONFIG_SHELL ./configure \
	--build=$GNU_BUILD --host=$GNU_HOST \
	--prefix=/ffp
make

cd ..
CFLAGS="-O2 -Ilibnbcompat" \
LIBS="libnbcompat/libnbcompat.a" \
$CONFIG_SHELL ./configure \
	--build=$GNU_BUILD --host=$GNU_HOST \
	--prefix=/ffp \
	--mandir=$mandir
make
make DESTDIR=$D install

_descr
_makepkg



