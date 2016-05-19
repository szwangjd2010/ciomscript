#!/usr/bin/env python
# -*- coding:utf-8 -*-

#导入模块
import os 
os.environ['NLS_LANG'] = 'SIMPLIFIED CHINESE_CHINA.UTF8' 

import cx_Oracle
import csv
import codecs
import sys  
reload(sys)  
sys.setdefaultencoding('utf8')

if len(sys.argv) != 2:
 print ('Need provide OrgId')
 sys.exit()

orgId = sys.argv[1]
sql="select CNNAME,DEPARTMENTNAME,USERNAME,ID from core_userprofile where orgid='%s'" % orgId
csv_file = "%s/user.%s.csv" % (os.environ["CIOM_SCRIPT_HOME"],orgId)
printHeader= True

if os.path.exists(csv_file):
 print "csv file existed,no need to import from db"
 sys.exit()

conn = cx_Oracle.connect('elearning/6r7dmU8H@10.200.60.100:1521/yxtdb')
curs = conn.cursor()
curs.execute(sql)

outputFile = open(csv_file,'w')
outputFile.write(codecs.BOM_UTF8)
output = csv.writer(outputFile,dialect='excel')

sys.stdout.write('Importing...\r')
sys.stdout.flush()

#print header
if printHeader:
 cols = []
 for col in curs.description:
  cols.append(col[0])
output.writerow(cols)

#write in detail
for row_data in curs:
 #rowdata=str(row_data).replace('(','(\"').replace(',','\",\"').replace(')','\")')
 #rowdata=str(row_data)
 #print rowdata
 output.writerow(row_data)

sys.stdout.write('Import Finished\n')
sys.stdout.flush()

outputFile.close()
curs.close ()
conn.close ()
