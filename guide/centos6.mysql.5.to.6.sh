#!/bin/bash
service mysqld stop
yum erase -y mysql-server mysql-libs mysql 
yum install -y http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum install -y mysql-community-client mysql-community-common mysql-community-libs mysql-community-server

/usr/bin/mysql_secure_installation

grant all privileges on *.* to root@'%' identified by 'pwdasdwx';
grant all privileges on *.* to yxt@'%' identified by 'pwdasdwx';
grant select on *.* to readonly@'%' identified by 'readonly';
grant select on *.* to nagios@'%' identified by 'nagios';
flush privileges;

CREATE DATABASE yxt DEFAULT CHARACTER SET utf8;