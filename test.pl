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

sub p($) {
    print((shift || "default") . "\n");
} 

sub a {
    my ($p1, $p2, $p3) = @_;

    p($p1);
    p($p2);
    p($p3);
}

sub b {
    my ($p1, $p2, $p3) = @_;
    
    a($p1, $p2, $p3);       
}

b(1, 2, 3);
b(1, 2);
b(1);
b();
