#!/usr/bin/perl -I /opt/ciom/ciom
use strict;
use English;
use Data::Dumper;
use Data::UUID;
my $ug = Data::UUID->new();	

my $b = "| grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";
my $suffix = "_android_#code#"; 
my $code = "1smart";
$suffix =~ s|#code#|$code|;

my $var = [1, 2];
$var="111";
if(ref($var) eq 'ARRAY') {
	print "array";
} else {
	print "not array";
}