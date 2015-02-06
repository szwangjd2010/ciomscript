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
		rate 100M;
		al-extents 257;
		on-no-data-accessible io-error;
	}
#	on Test1 {
#		device /dev/drbd0;
#		disk /dev/xvdb1;
#		address 192.168.0.16:7788;
#		flexible-meta-disk internal;
#	}
	on Test4 {
		device /dev/drbd0;
		disk /dev/xvdb1;
		address 192.168.0.19:7788;
		meta-disk internal;
	}
        on DB1 {
                device /dev/drbd0;
                disk /dev/xvdb1;
                address 192.168.0.9:7788;
                meta-disk internal;
        }
}
