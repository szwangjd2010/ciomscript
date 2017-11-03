#!/usr/bin/python
# -*- coding: UTF-8 -*-

import MySQLdb
import sys

year=sys.argv[1]
month=sys.argv[2]
sType=sys.argv[3]

# 打开数据库连接
db = MySQLdb.connect(host='172.17.128.23', port=3306, user = 'root', passwd='pwdasdwx',db='testlink')

# 使用cursor()方法获取操作游标 
cursor = db.cursor()

# SQL 查询语句
sqlCaseExcution = "SELECT t4.login AS LoginAccount ,t1.count1 AS total, IFNULL(t2.count2,0) AS pass ,IFNULL(t3.count3,0) AS fail FROM ((SELECT t.tester_id, COUNT(1) AS count1 FROM executions t WHERE t.tester_id IN (SELECT id FROM users) AND DATE_FORMAT(t.execution_ts,'%m')={0} AND DATE_FORMAT(t.execution_ts,'%Y')={1} GROUP BY t.tester_id) AS t1 LEFT JOIN (SELECT t.tester_id, COUNT(1) AS count2 FROM executions t WHERE t.tester_id IN (SELECT id FROM users) AND DATE_FORMAT(t.execution_ts,'%m')={0}  AND DATE_FORMAT(t.execution_ts,'%Y')={1}  AND t.status='p' GROUP BY t.tester_id) AS t2 ON t1.tester_id=t2.tester_id LEFT JOIN (SELECT t.tester_id, COUNT(1) AS count3 FROM executions t WHERE t.tester_id IN (SELECT id FROM users) AND DATE_FORMAT(t.execution_ts,'%m')={0}  AND DATE_FORMAT(t.execution_ts,'%Y')={1}  AND t.status='f' GROUP BY t.tester_id) AS t3 ON t1.tester_id=t3.tester_id LEFT JOIN users t4 ON t1.tester_id = t4.id)".format(month,year)

sqlCaseManagement = "SELECT t4.login AS \"Login Account\", IFNULL(t1.count1,0) AS \"Case Added\" ,IFNULL(t2.count2,0) AS \"Cases Updated\" FROM users t4 LEFT JOIN (SELECT t.author_id AS userid, COUNT(1) AS count1 FROM tcversions t WHERE t.author_id IN (SELECT id FROM users) AND DATE_FORMAT(t.creation_ts,'%m')={0} AND DATE_FORMAT(t.creation_ts,'%Y')={1}  GROUP BY t.author_id) t1 ON t4.id = t1.userid LEFT JOIN (SELECT t.updater_id AS userid, COUNT(1) AS count2 FROM tcversions t WHERE t.updater_id IN (SELECT id FROM users) AND DATE_FORMAT(t.modification_ts,'%m')={0}  AND DATE_FORMAT(t.modification_ts,'%Y')={1}  GROUP BY t.updater_id) t2 ON t4.id = t2.userid WHERE t1.count1 IS NOT NULL OR t2.count2 IS NOT NULL".format(month,year)

if sType == "CaseExecution" :
  print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  print "   Below is the case execution status for users within {0}-{1}".format(year,month)
  print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  sql = sqlCaseExcution

if sType == "CaseManagement":
  print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  print "   Below is the case add/update status for users within {0}-{1}".format(year,month)
  print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  sql = sqlCaseManagement

try:
  # 执行SQL语句
  cursor.execute(sql)
  # 获取所有记录列表
  results = cursor.fetchall()

  if sType == "CaseExecution" :
    print "LoginAccount\tTotal\tPassed\tFailed"
    for row in results:
      account = row[0]
      total = row[1]
      passed = row[2]
      failed = row[3]
      # 打印结果
      if len(account) >= 8:
        filltab = "\t"
      else:
        filltab = "\t\t"
      print "{1}{0}{2}\t{3}\t{4}".format(filltab,account,total,passed,failed)

  if sType == "CaseManagement":
    print "Login Account\tCases Added\tCases Updated"
    for row in results:
      account = row[0]
      addCnt = row[1]
      updateCnt = row[2]
      # 打印结果
      if len(account) >= 8:
        filltab = "\t"
      else:
        filltab = "\t\t"
      print "{1}{0}{2}\t\t{3}".format(filltab,account,addCnt,updateCnt)

except:
   print "Error: unable to fecth data"

# 关闭数据库连接
db.close()
