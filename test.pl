#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;

use CiomUtil;
use Math;


my $a = 6 % 7 || 1;

my $aa = {
	a => 0
};
print Math.min(10, 9);


#$util->remoteExec("192.168.0.125", "22", "echo aaa >> /tmp/_1; echo bbb >> /tmp/_1");