-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS qida_actionlog (
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

ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE qida_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mall_actionlog (
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

ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE mall_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wangxiao_actionlog (
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

ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE wangxiao_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lecai_actionlog (
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

ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE lecai_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS crm_actionlog (
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

ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE crm_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS zhibo_actionlog (
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

ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE zhibo_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS xuanke_actionlog (
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

ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE xuanke_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');


-----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS kachang_actionlog (
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

ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='01');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='02');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='03');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='04');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='05');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='06');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='07');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='08');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='09');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='10');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='11');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2017', month='12');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='01');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='02');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='03');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='04');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='05');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='06');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='07');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='08');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='09');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='10');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='11');
ALTER TABLE kachang_actionlog ADD IF NOT EXISTS PARTITION (year='2018', month='12');




