#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;

use CiomUtil;


my $a = 6 % 7 || 1;


print int(10/3);


#$util->remoteExec("192.168.0.125", "22", "echo aaa >> /tmp/_1; echo bbb >> /tmp/_1");