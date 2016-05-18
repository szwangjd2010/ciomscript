-----------------------------------------------------------------------------
DROP TABLE IF EXISTS qida_actionlog;
CREATE TABLE qida_actionlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	positionid STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	target STRING,
	subtarget STRING,
	attribute STRING,
	description STRING,
	source STRING,
	latitude STRING,
	longitude STRING,
	logcontent STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE qida_actionlog ADD PARTITION (year="2015", month='12');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='01');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='02');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='03');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='04');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='05');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='06');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='07');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='08');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='09');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='10');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='11');
ALTER TABLE qida_actionlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS qida_accesslog;
CREATE TABLE qida_accesslog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	pagename STRING,
	ip STRING,
	pageuri STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	positionname STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	source STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE qida_accesslog ADD PARTITION (year="2015", month='12');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='01');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='02');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='03');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='04');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='05');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='06');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='07');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='08');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='09');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='10');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='11');
ALTER TABLE qida_accesslog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS mall_actionlog;
CREATE TABLE mall_actionlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	positionid STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	target STRING,
	subtarget STRING,
	attribute STRING,
	description STRING,
	source STRING,
	latitude STRING,
	longitude STRING,
	logcontent STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE mall_actionlog ADD PARTITION (year="2015", month='12');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='01');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='02');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='03');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='04');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='05');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='06');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='07');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='08');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='09');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='10');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='11');
ALTER TABLE mall_actionlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS mall_accesslog;
CREATE TABLE mall_accesslog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	pagename STRING,
	ip STRING,
	pageuri STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	positionname STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	source STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE mall_accesslog ADD PARTITION (year="2015", month='12');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='01');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='02');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='03');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='04');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='05');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='06');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='07');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='08');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='09');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='10');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='11');
ALTER TABLE mall_accesslog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS wangxiao_actionlog;
CREATE TABLE wangxiao_actionlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	positionid STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	target STRING,
	subtarget STRING,
	attribute STRING,
	description STRING,
	source STRING,
	latitude STRING,
	longitude STRING,
	logcontent STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE wangxiao_actionlog ADD PARTITION (year="2015", month='12');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='01');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='02');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='03');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='04');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='05');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='06');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='07');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='08');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='09');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='10');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='11');
ALTER TABLE wangxiao_actionlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS wangxiao_accesslog;
CREATE TABLE wangxiao_accesslog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	pagename STRING,
	ip STRING,
	pageuri STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	positionname STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	source STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE wangxiao_accesslog ADD PARTITION (year="2015", month='12');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='01');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='02');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='03');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='04');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='05');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='06');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='07');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='08');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='09');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='10');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='11');
ALTER TABLE wangxiao_accesslog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS lecai_actionlog;
CREATE TABLE lecai_actionlog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	serverip STRING,
	clientip STRING,
	pageuri STRING,
	actionurl STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	positionid STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	target STRING,
	subtarget STRING,
	attribute STRING,
	description STRING,
	source STRING,
	latitude STRING,
	longitude STRING,
	logcontent STRING,
	referstr1 STRING,
	referstr2 STRING,
	referstr3 STRING,
	referstr4 STRING,
	referstr5 STRING,
	referstr6 STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE lecai_actionlog ADD PARTITION (year="2015", month='12');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='01');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='02');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='03');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='04');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='05');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='06');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='07');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='08');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='09');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='10');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='11');
ALTER TABLE lecai_actionlog ADD PARTITION (year='2016', month='12');


-----------------------------------------------------------------------------
DROP TABLE IF EXISTS lecai_accesslog;
CREATE TABLE lecai_accesslog (
	orgid STRING,
	orgname STRING,
	logtitle STRING,
	pagename STRING,
	ip STRING,
	pageuri STRING,
	querySTRING STRING,
	userid STRING,
	username STRING,
	usercnname STRING,
	sex STRING,
	ouid STRING,
	ouname STRING,
	positionid STRING,
	positionname STRING,
	useragent STRING,
	referurl STRING,
	method STRING,
	source STRING,
	logtime timestamp
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE lecai_accesslog ADD PARTITION (year="2015", month='12');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='01');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='02');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='03');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='04');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='05');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='06');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='07');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='08');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='09');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='10');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='11');
ALTER TABLE lecai_accesslog ADD PARTITION (year='2016', month='12');



