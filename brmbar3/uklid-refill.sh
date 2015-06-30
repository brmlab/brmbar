#!/bin/bash

if [ `./brmbar-cli.py iteminfo uklid|grep -o '[0-9]*.[0-9]* pcs'|cut -d '.' -f 1` -eq 0 ]; then 
	BOUNTY=`./brmbar-cli.py restock uklid 1 | grep -o 'take -[0-9]*'|grep -o '[0-9]*'`
	echo "Brmlab cleanup bounty for ${BOUNTY}CZK!!!"|ssh jenda@fry.hrach.eu
fi
