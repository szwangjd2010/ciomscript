#!/bin/bash
#

Ciom_Svn_Root="/var/www/svn"
Ciom_Svn_Backup_Location="/tech/backup"
Ciom_Svn_Timestamp=$(date +%04Y%02m%02d)


getDumpoutFileName() {
	reposName=$1
	echo $reposName.$Ciom_Svn_Timestamp
}

dump() {
	reposName=$1
	fileDumpoutName=$2

	echo "dump svn repository to $fileDumpoutName..."
	svnadmin dump $Ciom_Svn_Root/$reposName > /tmp/$fileDumpoutName
}

backup() {
	reposName=$1
	fileDumpoutName=$(getDumpoutFileName $reposName)

	dump $reposName $fileDumpoutName
	cp /tmp/$fileDumpoutName $Ciom_Svn_Backup_Location/
}