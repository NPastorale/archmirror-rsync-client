#!/bin/bash

OPTIONS="-rtlhH4 --stats --no-motd --safe-links --delete-after --delay-updates --exclude=lastsync"
SOURCE_LASTUPDATE=0
SOURCE_LASTUPDATE_PREVIOUS=0
DESTINATION=/data/
MIRRORS_FILE=/mirrors.txt

if [ ! -f ${DESTINATION}lastupdate ]
then
	echo "0" > ${DESTINATION}lastupdate
	echo "Priming lastupdate"
fi

STARTTIME=$(date +%s)
echo "Started $(date)"

shuf -o $MIRRORS_FILE $MIRRORS_FILE

while read p; do
	SOURCE_LASTUPDATE=$(curl -s https://${p}lastupdate)
	echo "$(date -Iseconds -d @${SOURCE_LASTUPDATE}) last update for $(echo $p | cut -f1 -d"/")"
	if [ $SOURCE_LASTUPDATE -gt $SOURCE_LASTUPDATE_PREVIOUS ] && [ $SOURCE_LASTUPDATE -gt 0 ] ; then
		SOURCE=$p
		SOURCE_LASTUPDATE_PREVIOUS=$SOURCE_LASTUPDATE
	fi
done < $MIRRORS_FILE

if [ $(cat ${DESTINATION}lastupdate) -lt $SOURCE_LASTUPDATE ]
then
	echo "Syncing with $(echo $SOURCE | cut -f1 -d"/")"

	rsync $OPTIONS rsync://$SOURCE $DESTINATION

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