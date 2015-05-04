#!/usr/bin/python

import MySQLdb
import time

connMaster = MySQLdb.connect(host='10.10.71.70',user='yxt',passwd='hzyxtDUANG2015',db='yxt')
connSlave = MySQLdb.connect(host='10.10.77.173',user='yxt',passwd='hzyxtDUANG2015',db='yxt')

curMaster = connMaster.cursor()
curSlave = connSlave.cursor()

for i in range(0, 10):
	newName = 'name-{0}'.format(i)
	curMaster.execute("update fortest set name=%s where pid='1'", newName)
	connMaster.commit()
	time.sleep(1.0 * i / 1000.0)

	curSlave.execute("select name from fortest where pid='1'")
	print newName 
	print curSlave.fetchone()
	print ''


curMaster.close()
curSlave.close()
connMaster.close()
connSlave.close()	



