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

my $appName = "DVD";
my $cmds = [
	"%AppRoot%/dist^",
	"%AppRoot%/%AppRoot%/dist^"
];

print "%%";

	foreach my $section qw(build package) {
		print "$section\n";
	}

print Dumper($cmds);
print Dumper(@{$cmds});

@{$cmds} = map {$_ =~ s|%AppRoot%|$appName|g;  $_;}  @{$cmds};

print Dumper($cmds);
