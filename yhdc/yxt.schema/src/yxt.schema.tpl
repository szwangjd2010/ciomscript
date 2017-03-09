<#list Products as product>
  <#list LogTypes as logType>
  <#assign tableName = product + "_" + logType + "log">
  <#assign filedsFile = "/include/" + logType + ".log.fields">
-----------------------------------------------------------------------------
<#if AddDropTableDDL == 1>
DROP TABLE IF EXISTS ${tableName};
</#if>
CREATE TABLE IF NOT EXISTS ${tableName} (
  <#include filedsFile>
) 
PARTITIONED BY (year STRING, month STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

<#list 2016..2018 as year>
  <#list 1..12 as month>
ALTER TABLE ${tableName} ADD IF NOT EXISTS PARTITION (year='${year}', month='${month?left_pad(2, '0')}');
  </#list>
</#list>


  </#list>
</#list>

<@pp.renameOutputFile extension='${LogTypes?join(".")}.sql' />

