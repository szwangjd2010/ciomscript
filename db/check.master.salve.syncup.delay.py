#!/usr/bin/python

import MySQLdb
import time

connMaster = MySQLdb.connect(host='10.10.71.70',user='yxt',passwd='hzyxtDUANG2015',db='yxt')
connSlave = MySQLdb.connect(host='10.10.77.173',user='yxt',passwd='hzyxtDUANG2015',db='yxt')
connSlave2 = MySQLdb.connect(host='10.10.65.89',user='yxt',passwd='hzyxtDUANG2015',db='yxt')

curMaster = connMaster.cursor()
curSlave = connSlave.cursor()
curSlave2 = connSlave2.cursor()

for i in range(0, 10):
	newName = 'pid.userid,knowledgeId-{0}'.format(i)
	#curMaster.execute("update fortest set name=%s where pid='1'", newName)
	curMaster.execute("insert into core_user_knowledge (pid, userId, knowledgeId) values (%s, %s, %s)", (newName, newName, newName))
	connMaster.commit()
	time.sleep(1.0 * i / 1000.0)

	#curSlave.execute("select name from fortest where pid='1'")
	print newName 
	curSlave.execute("select pid, userId, knowledgeId from core_user_knowledge WHERE pid=%s", newName)
	print curSlave.fetchone()
	curSlave2.execute("select pid, userId, knowledgeId from core_user_knowledge WHERE pid=%s", newName)
	print curSlave2.fetchone()
	
	print ''


curMaster.close()
curSlave.close()
curSlave2.close()
connMaster.close()
connSlave.close()	
connSlave2.close()	



