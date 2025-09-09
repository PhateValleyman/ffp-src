#!/ffp/bin/sh

DATE=$(date "+%Y%m%d_%H%M%S")

if	[ -f /ffp/start/tvheadend.sh.new ] && [ "$(md5sum /ffp/start/tvheadend.sh.new|awk '{print $1}')" = CHECKSUM ]
then
	if	[ -f /ffp/start/tvheadend.sh ]
	then
		mv /ffp/start/tvheadend.sh /ffp/start/tvheadend.sh.old"${DATE}"
		chmod 644 /ffp/start/tvheadend.sh.old"${DATE}"
		mv /ffp/start/tvheadend.sh.new /ffp/start/tvheadend.sh
	else
		mv /ffp/start/tvheadend.sh.new /ffp/start/tvheadend.sh
	fi
fi
if	[ -f /ffp/start/tvheadend.sh.new ] && [ "$(md5sum /ffp/start/tvheadend.sh.new|awk '{print $1}')" != CHECKSUM ]
then
	rm /ffp/start/tvheadend.sh.new
fi
if	[ ! -d /ffp/etc/tvheadend/accesscontrol ]
then
	mkdir -p /ffp/etc/tvheadend/accesscontrol
	cat > /ffp/etc/tvheadend/accesscontrol/1 << EOF
{
	"enabled": 1,
	"username": "tvheadend",
	"comment": "Default access entry",
	"prefix": "0.0.0.0/0,::/0",
	"streaming": 1,
	"dvr": 1,
	"dvrallcfg": 1,
	"webui": 1,
	"admin": 1,
	"tag_only": 0,
	"adv_streaming": 1,
	"password": "12345678"
}
EOF
	chmod -R 700 /ffp/etc/tvheadend/accesscontrol
fi
if	[ ! -d /ffp/etc/tvheadend/dvr ]
then
	mkdir -p /ffp/etc/tvheadend/dvr
	cat > /ffp/etc/tvheadend/dvr/config << EOF
{
	"storage": "/mnt/HD_a2/video",
	"file-permissions": "0664",
	"directory-permissions": "0775",
	"cache": 2,
	"retention-days": 31,
	"pre-extra-time": 0,
	"post-extra-time": 0,
	"day-dir": 0,
	"channel-dir": 0,
	"channel-in-title": 0,
	"date-in-title": 0,
	"time-in-title": 0,
	"whitespace-in-title": 0,
	"title-dir": 0,
	"episode-in-title": 0,
	"clean-title": 0,
	"tag-files": 1,
	"skip-commercials": 1,
	"subtitle-in-title": 0,
	"episode-before-date": 0,
	"episode-duplicate-detection": 0,
	"charset": "ASCII",
	"name": "",
	"profile": "matroska"
}
EOF
	chmod -R 700 /ffp/etc/tvheadend/dvr
fi
