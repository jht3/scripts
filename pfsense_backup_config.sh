#!/bin/sh

hostname="fw-01"
username="admin"
password="pfsense"
outfile="config-$hostname-`date +%Y%m%d%H%M%S`.xml"

if [ -f cookies.txt ]; then
  rm cookies.txt
fi

wget -qO- --keep-session-cookies --save-cookies cookies.txt \
  --no-check-certificate http://$hostname/diag_backup.php \
  | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt

wget -qO- --keep-session-cookies --load-cookies cookies.txt \
  --save-cookies cookies.txt --no-check-certificate \
  --post-data "login=Login&usernamefld=$username&passwordfld=$password&__csrf_magic=$(cat csrf.txt)" \
  http://$hostname/diag_backup.php  | grep "name='__csrf_magic'" \
  | sed 's/.*value="\(.*\)".*/\1/' > csrf2.txt

wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate \
  --post-data "Submit=download&donotbackuprrd=yes&__csrf_magic=$(head -n 1 csrf2.txt)" \
  http://$hostname/diag_backup.php -O $outfile

if [ -f cookies.txt ]; then
  rm cookies.txt
fi
if [ -f csrf.txt ]; then
  rm csrf.txt
fi
if [ -f csrf2.txt ]; then
  rm csrf2.txt
fi
