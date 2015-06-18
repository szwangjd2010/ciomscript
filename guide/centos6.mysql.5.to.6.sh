#!/bin/bash
service mysqld stop
yum erase -y mysql-server mysql-libs mysql 
yum install -y http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum install -y mysql-community-client mysql-community-common mysql-community-libs mysql-community-server

/usr/bin/mysql_secure_installation

grant all privileges on *.* to root@'%' identified by 'pwdasdwx';
grant select,delete,update on yxt.* to ciom@'%' identified by 'pwdasdwx';
grant all privileges on *.* to yxt@'%' identified by 'pwdasdwx';
grant select on *.* to readonly@'%' identified by 'readonly';
grant select on *.* to nagios@'%' identified by 'nagios';
flush privileges;

grant all privileges on yxt.* to yxt@'%' identified by 'hzyxtDUANG2015';

set password for 'yxt'@'10.10.%' = password('hzyxtDUANG2015');


CREATE DATABASE yxt DEFAULT CHARACTER SET utf8;

SHOW GRANTS FOR 'rfc'@'localhost';
REVOKE UPDATE, DELETE ON classicmodels.*  FROM 'rfc'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'rfc'@'localhost';