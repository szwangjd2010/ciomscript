http://blog.csdn.net/clementad/article/details/46898091

1. create wandisco-svn repo
# vi /etc/yum.repos.d/wandisco-svn.repo
[WandiscoSVN]
name=Wandisco SVN Repo
baseurl=http://opensource.wandisco.com/centos/7/svn-1.9/RPMS/$basearch/
enabled=1
gpgcheck=0


2. remove exists subversion packages, and clean yum cache
# yum remove subversion*
# yum clean all

3. install
# yum install subversion
if occur following error
Error: Package: subversion-1.8.11-1.x86_64 (WandiscoSVN)
Requires: libserf-1.so.0()(64bit)

install epel-release first
# yum install epel-release

then, try install again
# yum install subversion