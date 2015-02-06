find /opt/tomcat7-* -name server.xml \
-exec perl \
-i.$(date +%04Y%02m%02d.%02k%02M%02S) \
-p -e 's/acceptCount="\d+"/acceptCount="500"/g' {} \;

rpm -ivh http://mirrors.kernel.org/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm

#disk write benchmark
dd if=/dev/zero of=/tmp/1111 bs=4k count=16k conv=fdatasync

#network brandwidth benchmark
IPERF: How to test network Speed,Performance,Bandwidth
server
iperf -s #tcp
iperf -s -u #udp

client
iperf -c %serverIp%
iperf -c %serverIp% -u -b 10000m