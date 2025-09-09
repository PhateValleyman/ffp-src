#!/ffp/bin/bash -e

A=$(ls portmap-*.t*)
P=${A%.t*}

. ./funpkg.inc
_begin

cd portmap_$PV
patch -p1 -i $X/portmap-6.0-no-wrap.patch

make CC=gcc LDFLAGS="$FFP_LDFLAGS" DAEMON_UID=0 DAEMON_GID=0

mkdir -p $D/ffp/sbin
install -m 0755 pmap_dump pmap_set $D/ffp/sbin
install -m 0755 portmap $D/ffp/sbin/rpc.portmap

mkdir -p $D$mandir/man8
install -m 0644 portmap.man $D$mandir/man8/pmap_dump.8
install -m 0644 portmap.8 pmap_set.8 $D$mandir/man8

_start $X/start-*.sh

_doc BLURBv5 CHANGES README*
_descr
_makepkg

