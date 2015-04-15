#!/usr/bin/perl -I /var/lib/jenkins/workspace/ciom
use strict;
use English;
use Data::Dumper;


my $a = 6 % 7 || 1;

my $aa = {
	a => 0,
	b => 1,
	c => 2
};

sub f($) {
	my $a = shift;
	print Dumper(shift);
}

f(($aa->{a} = 100);

print Dumper($aa);
