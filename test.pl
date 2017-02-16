#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;


sub escapeRe($) {
	my $re = shift;
	#single quotation enclosed by single quotation
	$re =~ s/'/'"'"'/g;

	#vertical bar 
	$re =~ s/\|/\\|/g;	
	return $re;
}

my $arr = [
	{
		re => "aaaRE'",
		to => 'aaaTO|'
	},
	{
		re => 'bbbRE|',
		to => 'bbbTO|'
	}

];

foreach my $vi (@{$arr}) {
			$vi->{re} = escapeRe($vi->{re});
			$vi->{to} = escapeRe($vi->{to});
}

print Dumper($arr);