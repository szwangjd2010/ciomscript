#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;


my $a = [
"1",
"2"
];

print join(";", @{$a});