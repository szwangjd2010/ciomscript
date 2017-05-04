#!/usr/bin/perl -W
#
package T123;
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;

my $p1 = $ARGV[0] || 'm2';

sub way_m1() {
    p("m1");
}

sub way_m2() {
    p("m2");
}

sub p {
    my ($l) = @_;
    print "$l\n";
}


sub f1 {
    my ($a, $b) = @_;
    p($a);
    p($b);

    f2(@_);
}

sub f2 {
    my ($a, $b) = @_;
    p($a);
    p($b);
}



p(lc("AAAAAAAAAAAAAAAccc"));

