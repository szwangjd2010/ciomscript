#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;


sub a {
    local *b = sub {
        my ($v1, $v2) = @_;

        print $v1 . "\n";
        print $v2 . "\n";
        return 123;
    };
    return b(11, 22);  # Works as expected
}


a();

my $repos = [1,2,3];
foreach my $repo (@{$repos}) {
    print $repo . "\n";
}
