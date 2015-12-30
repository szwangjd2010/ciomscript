#!/bin/bash


umount //172.17.125.4/d$/Inetpub/eSchoolMedia20/
umount //172.17.125.4/d$/Inetpub/eLearningMedia/
umount //172.17.125.3/d$/oceansoft/eschoolMedia/
umount //172.17.125.3/d$/oceansoft/elearningMedia/
umount //10.10.132.147/oceansoft/

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.4/d$/Inetpub/eSchoolMedia20/ /mnt/eschoolmedia-dev

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.4/d$/Inetpub/eLearningMedia/ /mnt/elmedia-dev

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.3/d$/oceansoft/eschoolMedia/ /mnt/eschoolmedia-dev-simulation/

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.3/d$/oceansoft/elearningMedia/ /mnt/elmedia-dev-simulation/

mount -t cifs -o gid=jenkins,uid=jenkins,username=oceansoft,password='6h+98e7f' //10.10.188.41/oceansoft/ /mnt/elesmedia-ucloud
