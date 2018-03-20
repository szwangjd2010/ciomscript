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
use File::Path qw(make_path remove_tree);

make_path("/tmp/1111/2222/3333") || die "error in creating dir";


my %h1 = (a => 'a', b => 'b');
print Dump(%h1);
print $h1{a} . "\n";
print $h1{b} . "\n";

