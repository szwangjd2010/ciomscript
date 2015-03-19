#!/bin/bash
# ciom prebuild extra action
#

#named group usage
perl -0 -i -pE \
's|(?<g1><artifactId>waf</artifactId>\s+<version>)(?<g2>[^<>]+)(?<g3></version>)|$+{g1}$+{g2}-bvt$+{g3}|sg' \
$WORKSPACE/api/pom.xml

#anonymous group usage
perl -0 -i -pE \
's|(<artifactId>waf</artifactId>\s+<version>)([^<>]+)(</version>)|${1}${2}-bvt${3}|sg' \
$WORKSPACE/api/pom.xml
