#!/bin/bash

heartbeat
rpm -ivUh epel-release-6-5.noarch.rpm
yum --enablerepo=epel install heartbeat -y


drbd
rpm -ivh http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm
yum -y install drbd84-utils kmod-drbd84

#Insert drbd module manually on both machines or reboot:
/sbin/modprobe drbd

vi /etc/drbd.d/xxmysqldb.res

resource xxmysqldb {
	startup {
		wfc-timeout 30;
		outdated-wfc-timeout 20;
		degr-wfc-timeout 30;
	}
	net {
		cram-hmac-alg sha1;
		shared-secret sync_disk;
	}
	syncer {
		rate 10M;
		al-extents 257;
		on-no-data-accessible io-error;
	}
	on DB1 {
		device /dev/drbd0;
		disk /dev/xvdb1;
		address 192.168.0.9:7788;
		flexible-meta-disk internal;
	}
	on Test4 {
		device /dev/drbd0;
		disk /dev/xvdb1;
		address 192.168.0.19:7788;
		meta-disk internal;
	}
}

drbdadm create-md xxmysqldb

service drbd start

#on primary 
drbdadm -- --overwrite-data-of-peer primary all