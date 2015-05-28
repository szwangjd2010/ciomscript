#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;
use Data::UUID;
my $ug = Data::UUID->new();	

print Dumper(%ENV);

my $a = readpipe("grep -c replacePmsInShellStreamedit deploy.mobile.app.pl");

my $b = "| grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'";
print $b;