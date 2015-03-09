LOAD DATA LOCAL INFILE '#LogFile#'
	REPLACE 
	INTO TABLE sys_eventlog
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	(
		pid,
		actionType,
		resultType,
		targert,
		url,
		description,
		userAgent,
		clientIp,
		eventTime,
		source,
		operator
	);