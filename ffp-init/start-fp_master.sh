#!/ffp/bin/sh

# PROVIDE: fp_master
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="fp.master"
command="/ffp/sbin/$name"
fp_master_flags=

run_rc_command "$1"

