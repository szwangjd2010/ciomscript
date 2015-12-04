#!/bin/bash


umount //172.17.125.4/d$/Inetpub/eSchoolMedia20/
umount //172.17.125.4/d$/Inetpub/eLearningMedia/
umount //172.17.125.3/d$/oceansoft/eschoolMedia/
umount //172.17.125.3/d$/oceansoft/elearningMedia/

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.4/d$/Inetpub/eSchoolMedia20/ /mnt/eschoolmedia-dev

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.4/d$/Inetpub/eLearningMedia/ /mnt/elmedia-dev

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.3/d$/oceansoft/eschoolMedia/ /mnt/eschoolmedia-dev-simulation/

mount -t cifs -o gid=jenkins,uid=jenkins,username=Administrator,password='yunxuetang0512!' //172.17.125.3/d$/oceansoft/elearningMedia/ /mnt/elmedia-dev-simulation/
