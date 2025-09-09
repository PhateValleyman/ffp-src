exec 3>&2
_echo() { echo "$@" >&3; }
_die() { echo "$@" >&3; exit 1; }
_warn() { echo "warning: $@" >&3; }

GNU_TARGET=$(gcc -dumpmachine)
GNU_HOST=$GNU_TARGET
GNU_BUILD=$GNU_TARGET

LINUX_ARCH=arm

FFP_ARCH=arm

FFP_LDFLAGS_RPATH="-Wl,-rpath,/ffp/lib"
FFP_LDFLAGS="$FFP_LDFLAGS_RPATH"

if [ ! -d "$TMPDIR" ]; then
	TMPDIR=/tmp
fi
export TMPDIR
export CONFIG_SHELL=/ffp/bin/bash
	
X=$(pwd)
PN=$(basename $X)

if [ -z "$A" -a -z "$P" ]; then
	A=$(ls -v $X/$PN-*.tar* 2>/dev/null | tail -n 1)
	if [ -r "$A" ]; then
		P=$(basename $A 2>/dev/null | sed 's,\.tar.*$,,')
	fi
fi
PV=${P#$PN-}

[ -n "$PR" ] || eval PR=$(cat PR 2>/dev/null)
[ -n "$PV" ] || eval PV=$(cat PV 2>/dev/null)
[ -n "$P"  ] || P="$PN-$PV"

W=$TMPDIR/$PN.funpkg
D=$W/pkg

docdir=/ffp/share/doc
mandir=/ffp/share/man
infodir=/ffp/share/info

_begin() {
	if [ -e "$W" ]; then
		_echo "$W exists. You have 3 seconds for Ctrl-C."
		sleep 3
		rm -rf "$W"
	fi
	mkdir "$W" && cd "$W" || _die "$W: Failed to create working directory"

	local f g
	for f in $A; do
		for g in "$f" "$X/$f"; do
			if [ -r "$g" ]; then
				_echo "Unpacking $g"
				tar xf "$g"
				break
			fi
		done
	done

	trap "_die Failed" ERR

	local logf=$W/$P.log
	_echo "Saving output in $logf"
	exec &>$logf
	set -x
}

_exampleconf() {
	local d=$D/ffp/share/examples/$PN
	mkdir -p $d
	cp -a "$@" $d/
}

_start() {
	local d=$D/ffp/start
	local f g
	mkdir -p $d
	for f in "$@"; do
		g=$(basename $f)
		install -m 0644 "$f" "$d/${g#start-}"
	done
}

_descr() {
	local f=${1:-$X/DESCR}
	mkdir -p $D/install
	install -m 0644 "$f" $D/install/DESCR || \
		_warn "Description file $f not found"
}

_doc() {
	mkdir -p $D$docdir/$P
	cp -ar "$@" $D$docdir/$P || \
		_warn "Error copying docs"
}

_strip() {
	local strip=${STRIP:-strip}
	for f in $(find "$@" -type f | file -f - 2>/dev/null | grep ': *ELF .*executable'    | cut -d: -f1); do
		echo "$strip --strip-unneeded $f"
	        $strip --strip-unneeded "$f"
	done
	for f in $(find "$@" -type f | file -f - 2>/dev/null | grep ': *ELF .*shared object' | cut -d: -f1); do
		echo "$strip --strip-debug $f"
	        $strip --strip-debug "$f"
	done
}

_compress_man() {
	if [ -d .$mandir ]; then
		for f in $(find .$mandir/man* -type f -a ! -name "*.gz"); do
			if [ -e "$f" ]; then
				#_print "gzip $f"
				gzip -9c "$f" >"$f.gz"
				for g in $(find .$mandir/man* -type f -samefile "$f" \! -path "$f" \! -name "*.gz"); do
					#_print "ln $f.gz $g.gz"
					ln "$f.gz" "$g.gz"
					rm "$g"
				done
				rm "$f"
			fi
		done
		for f in $(find .$mandir/man* -type l -a ! -name "*.gz"); do
			g=$(readlink "$f")
			#_print "ln -s $g.gz $f.gz"
			ln -s "$g.gz" "$f.gz"
			rm "$f"
		done
	fi
}

_compress_info() {
	if [ -d .$infodir ]; then
		rm -f .$infodir/dir;
		for f in $(find .$infodir -type f ! -name "*.gz"); do
			#_print "gzip $f"
			gzip -9 "$f"
		done
	fi
}

_makepkg() {
	local strip_flag=yes
	local compress_man_flag=yes
	local compress_info_flag=yes

	while [ $# -gt 0 ]; do
		case "$1" in
		--no-strip)
			strip_flag=no
			shift
			;;
		*)
			_die "_makepkg: Unknown option: $1"
			shift
			;;
		esac
	done

	local pf=${PF:-$PN-$PV-${PA:-$FFP_ARCH}-${PR:-1}}
	local pkg=$TMPDIR/$pf.txz

	pushd $D

	if ls | egrep -vx '(ffp|install)' &>/dev/null; then
		_warn "Package contains extra directories:" $(ls)
	fi
	
	if [ "$strip_flag" = "yes" ]; then
		_strip
	fi
	if [ "$compress_man_flag" = "yes" ]; then
		_compress_man
	fi
	if [ "$compress_info_flag" = "yes" ]; then
		_compress_info
	fi
	popd
	tar cf - -C $D . | xz -c >$pkg
	_echo "Package: $pkg"
}

# vim: syntax=sh

