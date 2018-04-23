-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecaiapi_eventlog (
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

ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='12');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='01');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='02');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='03');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='04');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='05');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='06');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='07');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='08');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='09');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='10');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='11');
ALTER TABLE lecaiapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecaiadminapi_eventlog (
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

ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='12');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='01');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='02');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='03');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='04');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='05');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='06');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='07');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='08');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='09');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='10');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='11');
ALTER TABLE lecaiadminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mallapi_eventlog (
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

ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='12');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='01');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='02');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='03');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='04');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='05');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='06');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='07');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='08');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='09');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='10');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='11');
ALTER TABLE mallapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS malladminapi_eventlog (
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

ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='12');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='01');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='02');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='03');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='04');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='05');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='06');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='07');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='08');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='09');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='10');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='11');
ALTER TABLE malladminapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS qidaapi_eventlog (
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

ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='12');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='01');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='02');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='03');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='04');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='05');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='06');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='07');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='08');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='09');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='10');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='11');
ALTER TABLE qidaapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS componentapi_eventlog (
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

ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2015', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2019', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2020', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2021', month='12');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='01');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='02');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='03');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='04');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='05');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='06');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='07');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='08');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='09');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='10');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='11');
ALTER TABLE componentapi_eventlog ADD IF NOT EXISTS PARTITION (year='2022', month='12');




