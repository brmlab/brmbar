#!/bin/bash
LASTIDF=/home/brmlab/uklid.last

LASTID=`cat $LASTIDF 2>/dev/null || echo 0`


RES=`psql brmbar -Atq -c "select id,description from transactions where id>$LASTID and description like 'BrmBar sale of 1x uklid%' LIMIT 1;"`
if [ ! -z "$RES" ]; then
	LASTID=`echo "$RES"|cut -d '|' -f 1`
	echo $LASTID > $LASTIDF
	
	WINNER=`echo "$RES"|grep -o 'to [^ ]*'|cut -d ' ' -f 2`
	if [ -z "$WINNER" ]; then
		WINNER="anonymous hunter"
	fi
	echo "Brmlab cleanup bounty was claimed by $WINNER! Thanks!"|ssh jenda@fry.hrach.eu
fi
	
