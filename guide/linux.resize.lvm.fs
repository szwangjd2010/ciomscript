vmware linux vm enlarge disk size
pre: add more size in vm setting

1. gparted live cd, resize disk partion
2. lvresize -L +80G /dev/centos_hadoop-zk1-root
3. xfs_growfs /dev/centos_hadoop-zk1-root