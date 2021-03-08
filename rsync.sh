#!/bin/bash

OPTIONS="-rtlhH4 --stats --no-motd --safe-links --delete-after --delay-updates --exclude=lastsync"
SOURCE_LASTUPDATE=0
SOURCE_LASTUPDATE_PREVIOUS=0
DESTINATION=/data/

if [ ! -f ${DESTINATION}lastupdate ]
then
	echo "0" > ${DESTINATION}lastupdate
	echo "Priming lastupdate"
fi

STARTTIME=$(date +%s)
echo "Started $(date)"

while read p; do
	SOURCE_LASTUPDATE=$(curl -s https://${p}lastupdate)
	echo "$(date -Iseconds -d @${SOURCE_LASTUPDATE}) last update for $(echo $p | cut -f1 -d"/")"
	if [ $SOURCE_LASTUPDATE -gt $SOURCE_LASTUPDATE_PREVIOUS ] && [ $SOURCE_LASTUPDATE -gt 0 ] ; then
		SOURCE_SECOND_BEST=$SOURCE
		SOURCE=$p
		SOURCE_LASTUPDATE_PREVIOUS=$SOURCE_LASTUPDATE
	fi
done < /mirrors.txt

if [ $(cat ${DESTINATION}lastupdate) -lt $SOURCE_LASTUPDATE ]
then
	echo "Starting sync. Using $(echo $SOURCE | cut -f1 -d"/") as primary, $(echo $SOURCE_SECOND_BEST | cut -f1 -d"/") as backup"

	if ! rsync $OPTIONS rsync://$SOURCE $DESTINATION
	then
		if ! rsync $OPTIONS rsync://$SOURCE_SECOND_BEST $DESTINATION
		then
			exit 1
		fi
	fi

	ENDTIME=$(date +%s)
	TOTALTIME=$(($ENDTIME-$STARTTIME))
	echo "Sync completed, took $(date -u -d @${TOTALTIME} +"%T")"
else
	ENDTIME=$(date +%s)
	TOTALTIME=$(($ENDTIME-$STARTTIME))
	echo "No sync necessary, took $(date -u -d @${TOTALTIME} +"%T")"
fi

date +%s > "${DESTINATION}lastsync"
echo "Finished $(date)"


#TODO change echo and add logging capabilities
#TODO investigate rsync over TLS https://dotsrc.org/mirrors/