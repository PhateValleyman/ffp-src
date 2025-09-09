#!/ffp/bin/bash -e
A=$(ls busybox-*.tar*)
S=$(basename ${A%.tar*})
PN=$(basename $(pwd))
P=$PN-${S##*-}
. ./funpkg.inc
_begin

cd $S

for p in $X/$S-*.patch; do
	[ -r "$p" ] && patch -p1 -i $p
done

patch -p1 -i $X/bb_bin.patch
patch -p1 -i $X/busybox-ffp.patch

cat $X/config >.config
yes '' | make oldconfig
make

bb_bin=$PN make CONFIG_PREFIX=$D/ffp install
rm -f $D/ffp/bin/bbconfig

_start $X/start-*.sh
_exampleconf $X/inetd.conf

mkdir -p $D$mandir/man1
cp docs/busybox.1 $D$mandir/man1/$PN.1
_doc AUTHORS LICENSE README
_descr
_makepkg

