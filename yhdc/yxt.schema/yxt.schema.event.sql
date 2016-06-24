-----------------------------------------------------------------------------
DROP TABLE IF EXISTS lecaiapi_eventlog;
CREATE TABLE lecaiapi_eventlog (
	pid STRING,
	actionType STRING,
	resultType STRING,
	target STRING,
	url STRING,
	description STRING,
	userAgent STRING,
	clientIp STRING,
	eventTime timestamp,
	source STRING,
	operator STRING,
	orgId STRING
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE lecaiapi_eventlog ADD PARTITION (year="2015", month='12');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='01');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='02');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='03');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='04');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='05');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='06');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='07');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='08');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='09');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='10');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='11');
ALTER TABLE lecaiapi_eventlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS lecaiadminapi_eventlog;
CREATE TABLE lecaiadminapi_eventlog (
	pid STRING,
	actionType STRING,
	resultType STRING,
	target STRING,
	url STRING,
	description STRING,
	userAgent STRING,
	clientIp STRING,
	eventTime timestamp,
	source STRING,
	operator STRING,
	orgId STRING
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year="2015", month='12');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS mallapi_eventlog;
CREATE TABLE mallapi_eventlog (
	pid STRING,
	actionType STRING,
	resultType STRING,
	target STRING,
	url STRING,
	description STRING,
	userAgent STRING,
	clientIp STRING,
	eventTime timestamp,
	source STRING,
	operator STRING,
	orgId STRING
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE mallapi_eventlog ADD PARTITION (year="2015", month='12');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='01');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='02');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='03');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='04');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='05');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='06');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='07');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='08');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='09');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='10');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='11');
ALTER TABLE mallapi_eventlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS malladminapi_eventlog;
CREATE TABLE malladminapi_eventlog (
	pid STRING,
	actionType STRING,
	resultType STRING,
	target STRING,
	url STRING,
	description STRING,
	userAgent STRING,
	clientIp STRING,
	eventTime timestamp,
	source STRING,
	operator STRING,
	orgId STRING
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE malladminapi_eventlog ADD PARTITION (year="2015", month='12');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='01');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='02');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='03');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='04');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='05');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='06');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='07');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='08');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='09');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='10');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='11');
ALTER TABLE malladminapi_eventlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS qidaapi_eventlog;
CREATE TABLE qidaapi_eventlog (
	pid STRING,
	actionType STRING,
	resultType STRING,
	target STRING,
	url STRING,
	description STRING,
	userAgent STRING,
	clientIp STRING,
	eventTime timestamp,
	source STRING,
	operator STRING,
	orgId STRING
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE qidaapi_eventlog ADD PARTITION (year="2015", month='12');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='01');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='02');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='03');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='04');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='05');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='06');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='07');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='08');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='09');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='10');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='11');
ALTER TABLE qidaapi_eventlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS componentapi_eventlog;
CREATE TABLE componentapi_eventlog (
	pid STRING,
	actionType STRING,
	resultType STRING,
	target STRING,
	url STRING,
	description STRING,
	userAgent STRING,
	clientIp STRING,
	eventTime timestamp,
	source STRING,
	operator STRING,
	orgId STRING
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE componentapi_eventlog ADD PARTITION (year="2015", month='12');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='01');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='02');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='03');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='04');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='05');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='06');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='07');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='08');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='09');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='10');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='11');
ALTER TABLE componentapi_eventlog ADD PARTITION (year='2016', month='12');



