<#list Products as product>
  <#list LogTypes as logType>
  <#assign tableName = product + "_" + logType + "log">
  <#assign filedsFile = "/include/" + logType + ".log.fields">
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS ${tableName};
CREATE TABLE ${tableName} (
  <#include filedsFile>
) 
PARTITIONED BY (year INT, month INT) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE ${tableName} ADD PARTITION (year=2015, month=12);
<#list 1..12 as month>
ALTER TABLE ${tableName} ADD PARTITION (year=2016, month=${month});
</#list>


  </#list>
</#list>