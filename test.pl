#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;


my $a = 6 % 7 || 1;

my $aa = {
	a => 0
};

my $names =[];
my $a = { vals => "'#pid#','#orgId#','#userId#','#userType#','#departmentId#'"};
my $aa = $a->{vals};
my $pid = "pid";
$aa =~ s/#$pid#/11111/g;

print $aa . "\n";
print Dumper($a);
