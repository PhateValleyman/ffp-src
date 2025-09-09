#!/ffp/bin/bash -e

P=ffp-scripts-0.6

. ./funpkg.inc
_begin

mkdir -p $D/ffp/etc
mkdir -p $D/ffp/etc/profile.d
cp -a $X/etc/* $D/ffp/etc/
rm -f $D/ffp/etc/*~

mkdir -p $D/ffp/sbin
install -m 0755 $X/store-passwd.sh $D/ffp/sbin

_exampleconf $X/examples/*
_start $X/start-*.sh

_descr
_makepkg

