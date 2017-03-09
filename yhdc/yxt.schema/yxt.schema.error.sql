-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS qida_errorlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querystring STRING,
	userid STRING,
	username STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	body STRING,
	referurl STRING,
	useragent STRING,
	source STRING,
	errorMessage STRING,
	errorMessageDetails STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE qida_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mall_errorlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querystring STRING,
	userid STRING,
	username STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	body STRING,
	referurl STRING,
	useragent STRING,
	source STRING,
	errorMessage STRING,
	errorMessageDetails STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE mall_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wangxiao_errorlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querystring STRING,
	userid STRING,
	username STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	body STRING,
	referurl STRING,
	useragent STRING,
	source STRING,
	errorMessage STRING,
	errorMessageDetails STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE wangxiao_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecai_errorlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querystring STRING,
	userid STRING,
	username STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	body STRING,
	referurl STRING,
	useragent STRING,
	source STRING,
	errorMessage STRING,
	errorMessageDetails STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE lecai_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS crm_errorlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querystring STRING,
	userid STRING,
	username STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	body STRING,
	referurl STRING,
	useragent STRING,
	source STRING,
	errorMessage STRING,
	errorMessageDetails STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='01');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='02');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='03');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='04');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='05');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='06');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='07');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='08');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='09');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='10');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='11');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2016', month='12');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE crm_errorlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');




