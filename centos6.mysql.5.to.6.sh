#!/bin/bash
service mysqld stop
yum erase -y mysql-server mysql-libs mysql 
yum install -y http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum install -y mysql-community-client mysql-community-common mysql-community-libs mysql-community-server

/usr/bin/mysql_secure_installation

grant all privileges on *.* to xxv2@'%' identified by 'xxv2__';
grant all privileges on *.* to root@'%' identified by 'P@ss~!@321';
grant select on *.* to readonly@'%' identified by 'readonly__';
flush privileges;
