#!/usr/bin/perl -W
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::Diver qw( Dive DiveRef DiveError );
use Hash::Merge qw( merge );
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";

my $a = {
	pre => [
		1,
		2
	],

	onlya => [
		'onlya-1'
	]
};

my $b = {
	pre => [
		3, 
		4
	],
	onlyb => [
		'onlyb-1'
	]

};

$b = merge $a, $b;
print 'RETAINMENT_PRECEDENT\n' . Dumper($b);

$b = merge $a, $b;
print 'RETAINMENT_PRECEDENT\n' . Dumper($b);