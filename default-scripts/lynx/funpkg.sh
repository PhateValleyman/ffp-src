#!/ffp/bin/bash -e

A=$(ls lynx*.tar*)
P=$(echo ${A%.tar*} | sed 's,lynx,&-,')

. ./funpkg.inc
_begin

cd lynx[0-9]*

LDFLAGS="$FFP_LDFLAGS" \
$CONFIG_SHELL ./configure \
	--build=$GNU_BUILD --host=$GNU_HOST \
	--prefix=/ffp \
	--mandir=$mandir \
	--datadir=/ffp/share/lynx \
	--enable-default-colors \
	--with-screen=ncursesw \
	--enable-widec \
	--enable-gzip-help \
	--with-zlib \
	--enable-read-eta \
	--enable-scrollbar \
	--with-ssl \
	--enable-color-style \
	--enable-prettysrc \
	--enable-source-cache \
	--enable-nsl-fork \
	--disable-nls \
	--enable-persistent-cookies \
	--enable-vertrace \
	--disable-full-paths \
	--enable-addrlist-page \
	--enable-charset-choice \
	--enable-htmlized-cfg \
	--enable-justify-elts \
	--enable-locale-charset \
	--enable-externs \
	--enable-cgi-links \
	--enable-change-exec \
	--enable-exec-links \
	--enable-exec-scripts \
	--enable-internal-links \
	--with-bzlib \
	--enable-ipv6

make
make DESTDIR=$D install install-help install-doc
_doc AUTHORS COPYING* PROBLEMS README 
_descr
_makepkg


