#!/usr/bin/perl -W
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Data::Diver qw( Dive DiveRef DiveError );
use Hash::Merge::Simple qw( merge );
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";


our $CiomData = json_file_to_perl("/opt/ciom/ciomscript/plugins/vue.ciom");

print Dumper($CiomData);
our $CiomUtil = new CiomUtil(0);

sub runCmds($) {
	my $cmdsHierarchy = shift;
	#my $cmds = Dive( $CiomData, qw(" $cmdsHierarchy "));
	my $cmds = Dive( $CiomData, split(' ', $cmdsHierarchy));

	print Dumper($cmds);
	if (!defined($cmds)) {
		return;
	}

	for (my $i = 0; $i <= $#{$cmds}; $i++) {
		$CiomUtil->exec($cmds->[$i]);
	}
}

sub build() {
	runCmds("build pre cmds");
	runCmds("build cmds");
	runCmds("build post cmds");
}

build();