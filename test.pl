#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;



my $a = {
	a => [0,1],
	b => [0,1]
};

my $b = {
	a => [2, 2],
	c => [0,1]
};


'0' ne '' &&  print 1;
