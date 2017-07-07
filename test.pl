#!/usr/bin/perl -W
#
package T123;
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;

my $a = "aaaaaaaa";

sub f($) {
    my $va = shift;
    $va =~ s/(\w+)/222222/g;

    print $va;
}

print $a;

f($a);

print $a;

