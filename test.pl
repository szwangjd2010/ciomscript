#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;


	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	print sprintf("%04d%02d%02d+%02d%02d%02d", 
		$year + 1900,
		$mon + 1,
		$mday,
		$hour,
		$min,
		$sec);