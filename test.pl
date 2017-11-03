#!/usr/bin/perl -W
#
package T123;
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;
use ScmActor;
use Text::Sprintf::Named qw(named_sprintf);
use Template;

my $Tpl;

my $a = '@hell0';
print $a . "\n";