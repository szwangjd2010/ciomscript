#!/bin/bash
# 
#

year=${1:-2017}
month=${2:-10}

host="172.17.128.23"
port="3306"
user="root"
password="pwdasdwx"
table="testlink"
sql="SELECT t4.login AS LoginAccount ,t1.count1 AS total, IFNULL(t2.count2,0) AS pass ,IFNULL(t3.count3,0) AS fail FROM ((SELECT t.tester_id, COUNT(1) AS count1 FROM executions t WHERE t.tester_id IN (SELECT id FROM users) AND DATE_FORMAT(t.execution_ts,'%m')=$month AND DATE_FORMAT(t.execution_ts,'%Y')=$year GROUP BY t.tester_id) AS t1 LEFT JOIN (SELECT t.tester_id, COUNT(1) AS count2 FROM executions t WHERE t.tester_id IN (SELECT id FROM users) AND DATE_FORMAT(t.execution_ts,'%m')=$month AND DATE_FORMAT(t.execution_ts,'%Y')=$year AND t.status='p' GROUP BY t.tester_id) AS t2 ON t1.tester_id=t2.tester_id LEFT JOIN (SELECT t.tester_id, COUNT(1) AS count3 FROM executions t WHERE t.tester_id IN (SELECT id FROM users) AND DATE_FORMAT(t.execution_ts,'%m')=$month AND DATE_FORMAT(t.execution_ts,'%Y')=$year AND t.status='f' GROUP BY t.tester_id) AS t3 ON t1.tester_id=t3.tester_id LEFT JOIN users t4 ON t1.tester_id = t4.id)"

mysql -h$host -P$port -u$user -p$password $table -e "$sql" > test.csv