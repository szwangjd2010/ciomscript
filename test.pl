#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;

use CiomUtil;

my $util = new CiomUtil(0);
use Data::UUID;
my $ug = Data::UUID->new();	

print $ug->create_str() . "\n";

#$util->remoteExec("192.168.0.125", "22", "echo aaa >> /tmp/_1; echo bbb >> /tmp/_1");