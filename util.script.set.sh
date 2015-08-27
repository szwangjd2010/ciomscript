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

winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{HOST="172.17.128.241";CertificateThumbprint="‎dbe11425f0bd2a60f1cf03cb02b6fafab0be7342"}

openssl req -x509 -config cert.request.tpl -extensions 'lle exts' -nodes\
 -days 1000 -newkey rsa:1024 -keyout myserver.key -out myserver.crt


perl -i.bak -p0E 
    's|(<artifactId>api</artifactId>[^<]+<version>)(bbb)(</version>)|\1a\3|smg' pom.xml
# named groups/backreferences
(?<name>groupPattern)   \g{name} -> in pattern, $+{name} -> outside of pattern
perl -p0E 's|(?<g1><stringProp name="Argument.name">ServerIP</stringProp>\s+<stringProp name="Argument.value">)[\w\.]+(?<g2></stringProp>)|$+{g1}1.1.1.1$+{g2}|smg' /tech/api.jmx | head -n 20

 A905295A5D17FB075828FD15BD36FD7D0B875F5B



find /data/ -name catalina.sh -exec sed -i '/# OS specific support/i CATALINA_OPTS="-Djava.library.path=/usr/local/apr/lib"' {} \;
find /data/ -name server.xml -exec sed -i 's/Http11NioProtocol/Http11AprProtocol/' {} \;