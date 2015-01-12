#!/bin/bash
MUSER="$1"
MPASS="$2"
MDB="$3"
MHOST="${4:-localhost}"
 
# Detect paths
MYSQL=$(which mysql)
 
# help
if [ $# -lt 3 ]; then
	echo "Usage: $0 {MySQL-User-Name} {MySQL-User-Password} {MySQL-Database-Name} [host-name]"
	echo "Drops all tables from a MySQL"
	exit 1
fi
 
# make sure we can connect to server
$MYSQL -u $MUSER -p$MPASS -h $MHOST -e "use $MDB" &>/dev/null
if [ $? -ne 0 ]; then
	echo "Error - Cannot connect to mysql server using given username, password or database does not exits!"
	exit 2
fi
 
TABLES=$($MYSQL -u $MUSER -p$MPASS -h $MHOST $MDB -BNe 'show tables')
 
# make sure tables exits
if [ "$TABLES" == "" ]; then
	echo "Error - No table found in $MDB database!"
	exit 3
fi
 
# let us do it
echo "Begin drop all tables in database $MDB..."
for t in $TABLES; do
	echo "deleting $t table..."
	$MYSQL -u $MUSER -p$MPASS -h $MHOST $MDB -e "drop table $t"
done
echo "All tables dropped!"