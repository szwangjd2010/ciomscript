#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;

use CiomUtil;

my $util = new CiomUtil(0);
print $ENV{CIOM_HOME};
$util->exec('echo "sdafsdf"');


print "1\
2\
3\
4";

#$util->remoteExec("192.168.0.125", "22", "echo aaa >> /tmp/_1; echo bbb >> /tmp/_1");
