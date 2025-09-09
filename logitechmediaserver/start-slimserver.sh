#!/ffp/bin/sh

# PROVIDE: slimserver
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="slimserver"
command="/ffp/lib/logitechmediaserver-7.7.1/slimserver.pl"
slimserver_flags="--nodebuglog --nosb1slimp3sync --notranscoding"

start_cmd="slimserver_start"
stop_cmd="slimserver_stop"

user=nobody

_sync() {
	let t=120
	while [ $t -gt 0 ]; do
		if netstat -tlnp 2>/dev/null | grep -wq 9000; then
			echo
			exit 0
		fi
		sleep 1
		echo -n .
		let t=t-1
	done
	echo " timed out"
	exit 1
}

_sync_down() {
	let t=120
	while [ $t -gt 0 ]; do
		if ! pidof slimserver.pl &>/dev/null; then
			echo
			exit 0
		fi
		sleep 1
		echo -n .
		let t=t-1
	done
	echo " timed out"
	exit 1
}
	
slimserver_start()
{
	if pidof slimserver.pl >/dev/null 2>&1; then
		echo "Already running"
	else
		cd $(dirname $command)
		chown -cR $user Logs Cache prefs
		su $user -p -c "nohup ./slimserver.pl $slimserver_flags >/dev/null 2>&1 &"
	fi
	#_sync
}

slimserver_stop()
{
	if ! pidof slimserver.pl &>/dev/null; then
		echo "Not running"
	else
		killall slimserver.pl 2>/dev/null
		#_sync_down
	fi
}

run_rc_command "$1"

