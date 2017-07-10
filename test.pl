#!/usr/bin/perl -W
#
package T123;
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;
use File::Find::Rule;
my $a = [
    {
        name => 'name1',
        url => "url1"
    },
    {
        name => 'name2',
        url => "url2-new"
    },
    {
        name => 'name3',
        url => "url3"
    }

];


my $b = [
    {
        name => 'name1',
        url => "url1"
    },
    {
        name => 'name2',
        url => "url2"
    }

];




my @d = File::Find::Rule->new
    ->directory
    ->in(".")
    ->maxdepth(1)
    ->not(File::Find::Rule->new->name(qr/^\.\.?$/));

