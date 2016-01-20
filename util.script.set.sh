find /opt/tomcat7-* -name server.xml \
-exec perl \
-i.$(date +%04Y%02m%02d.%02k%02M%02S) \
-p -e 's/acceptCount="\d+"/acceptCount="500"/g' {} \;

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

perl -i.bak -p0E 's|(<artifactId>api</artifactId>[^<]+<version>)(bbb)(</version>)|\1a\3|smg' pom.xml
# named groups/backreferences
(?<name>groupPattern)   \g{name} -> in pattern, $+{name} -> outside of pattern
perl -p0E 's|(?<g1><stringProp name="Argument.name">ServerIP</stringProp>\s+<stringProp name="Argument.value">)[\w\.]+(?<g2></stringProp>)|$+{g1}1.1.1.1$+{g2}|smg' /tech/api.jmx | head -n 20

find /data/ -name catalina.sh -exec sed -i '/# OS specific support/i CATALINA_OPTS="-Djava.library.path=/usr/local/apr/lib"' {} \;
find /data/ -name server.xml -exec sed -i 's/Http11NioProtocol/Http11AprProtocol/' {} \;
find /data -name ${product}_${type}.log -exec sh -c "tail -F {} | kafkacat -b $brokers -t ${product}.${type} &" \;

multibyte characters search
perl -ne '/\x{7528}\x{6237}.*"502"/ && print' qida_action.20160113.all-instances.log
python -c "print repr('用户登录'.decode('utf-8'))[2:-1]"
python -c "import re;print re.sub('u(\w{4})', 'x{\g<1>}', repr(' 用户登录'.decode('utf-8'))[2:-1])"
\x{7528}\x{6237}\x{767b}\x{5f55}

#dump http response
tcpdump -s 0 -A 'src port 80 and tcp[((tcp[12:1]&0xf0)>>2):4]=0x48545450'
tcpdump -s 0 -A 'src port 80 and tcp[((tcp[12:1]&0xf0)>>2):4]='$(python -c "print '0x' + ''.join(hex(ord(i))[2:] for i in 'HTTP')")

#dump http post request, following two are equal, 0x504f5354 <-> POST
tcpdump -s 0 -A 'dst port 80 and tcp[((tcp[12:1]&0xf0)>>2):4]=0x504f5354'
tcpdump -s 0 -A 'dst port 80 and tcp[((tcp[12:1]&0xf0)>>2):4]='$(python -c "print '0x' + ''.join(hex(ord(i))[2:] for i in 'POST')")

#dump http get request
tcpdump -s 0 -A 'dst port 80 and tcp[((tcp[12:1]&0xf0)>>2):4]='$(python -c "print '0x' + ''.join(hex(ord(i))[2:] for i in 'GET ')")