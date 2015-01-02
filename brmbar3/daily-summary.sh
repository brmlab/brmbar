#!/bin/sh
# Add a crontab entry like:
# 5 4  *   *    *    ~/brmbar/brmbar3/daily-summary.sh | mail -s "daily brmbar summary" rada@brmlab.cz
cd ~/brmbar/brmbar3
./brmbar-cli.py stats
echo
echo "Time since last full inventory check: $(echo "select now()-time from transactions where description = 'BrmBar inventory consolidation' order by time desc limit 1;" | psql brmbar | tail -n +3 | head -n 1 | tr -s " ")"
echo
echo "Overflows: $(echo "SELECT name, -crbalance FROM account_balances WHERE name LIKE '%overflow%' AND crbalance != 0 ORDER BY name" | psql brmbar | tail -n +3 | grep '|' | tr -s " " | sed -e "s/ |/:/g" -e "s/$/;/" | tr -d "\n")  TOTAL: $(echo "SELECT -SUM(crbalance) FROM account_balances WHERE name LIKE '%overflow%' AND crbalance != 0" | psql brmbar | tail -n +3 | head -n 1 | tr -s " ")"
echo
echo "Club Mate sold in last 24 hours: $(echo "select count(*) from transaction_cashsums where time > now() - '1 day'::INTERVAL and (description like '%Club Mate%' or description like '%granatove mate%')" | psql brmbar | tail -n +3 | head -n 1 | tr -s " ") bottles"
