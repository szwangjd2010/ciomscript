drop database if exists ranger;
drop database if exists ranger_audit;
drop database if exists rangerkms;
CREATE DATABASE ranger DEFAULT CHARACTER SET utf8;
CREATE DATABASE ranger_audit DEFAULT CHARACTER SET utf8;
CREATE DATABASE rangerkms DEFAULT CHARACTER SET utf8;

DELETE FROM mysql.user WHERE mysql.user.user LIKE 'ranger%';
grant all privileges on ranger.* to rangeradmin@'%' identified by 'lle' with grant option;
grant all privileges on ranger_audit.* to rangeradmin@'%'  with grant option;
grant all privileges on rangerkms.* to rangeradmin@'%'  with grant option;
grant all privileges on ranger_audit.* to rangerlogger@'%' identified by 'lle';
grant all privileges on rangerkms.* to rangerkms@'%' identified by 'lle';

flush privileges;
