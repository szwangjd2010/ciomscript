perl -0 -i -pE 's|(?<g1><artifactId>waf</artifactId>\s+<version>)(?<g2>[\w\.-]+)(?<g3></version>)|$+{g1}$+{g2}-bvt$+{g3}|smg' $WORKSPACE/waf/pom.xml
perl -0 -i -pE 's|(?<g1><stringProp name="Argument.name">ServerIP</stringProp>\s+<stringProp name="Argument.value">)[\w\.]+(?<g2></stringProp>)|$+{g1}172.17.128.232$+{g2}|smg' $WORKSPACE/waf/src/test/jmeter/api.jmx
perl -0 -i -pE 's|(?<g1><stringProp name="Argument.name">Port</stringProp>\s+<stringProp name="Argument.value">)[\d]+(?<g2></stringProp>)|$+{g1}8083$+{g2}|smg' $WORKSPACE/waf/src/test/jmeter/api.jmx