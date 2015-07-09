#!/usr/bin/perl -I /opt/ciom/ciomscript
use strict;
use English;
use Data::Dumper;
use Data::UUID;
my $ug = Data::UUID->new();	

my $aa = {
	"k1" => 1,
	"k2" => 2
};

my @b = (keys %{$aa});
print Dumper(\@b);


my $c=[];
print $#{[]};