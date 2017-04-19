#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;

my $p1 = $ARGV[0];


my $v = 
sub p {
    my ($l) = @_;
    print "${l}\n";
}

if ($p1 eq "DoRollback") {
    p("eq");
} else {
    p("ne");
}
