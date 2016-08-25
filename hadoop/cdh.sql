drop database if exists cdh_hive;
drop database if exists cdh_reportsmanager;
drop database if exists cdh_oozie;
CREATE DATABASE cdh_hive DEFAULT CHARACTER SET utf8;
CREATE DATABASE cdh_reportsmanager DEFAULT CHARACTER SET utf8;
CREATE DATABASE cdh_oozie DEFAULT CHARACTER SET utf8;

DELETE FROM mysql.user WHERE mysql.user.user LIKE 'cdh_%';
grant all privileges on cdh_hive.* to cdh_hive@'%' identified by 'lle' with grant option;
grant all privileges on cdh_reportsmanager.* to cdh_rptmgr@'%' identified by 'lle' with grant option;
grant all privileges on cdh_oozie.* to cdh_oozie@'%' identified by 'lle' with grant option;

flush privileges;