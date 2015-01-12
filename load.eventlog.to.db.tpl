LOAD DATA LOCAL INFILE '#LogFile#'
	REPLACE 
	INTO TABLE t_eventlog
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	(
		p_id, 
		s_devicetype, 
		s_eventtype, 
		s_eventobject, 
		s_eventdesc, 
		s_useragent, 
		s_eventtime, 
		s_user_id, 
		s_userphone, 
		s_status
	);