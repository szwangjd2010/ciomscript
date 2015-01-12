find /opt/tomcat7-* -name server.xml \
-exec perl \
-i.$(date +%04Y%02m%02d.%02k%02M%02S) \
-p -e 's/acceptCount="\d+"/acceptCount="500"/g' {} \;

rpm -ivh http://mirrors.kernel.org/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm