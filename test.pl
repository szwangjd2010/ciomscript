#!/usr/bin/perl -W
#
use Data::Dumper;
use bigint;
use JSON::Parse 'json_file_to_perl';
use JSON;
use Cwd;
use POSIX qw(strftime);

my $h = {};

if (!%{$h}) { 
    print "Empty\n";
} 

my $a =[];

if (!@{$a}) {
	print "Zero length\n"
}
my $b;
if (!defined($b)) {
	print "b is undef\n";
}
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

printf("Time Format - HH:MM:SS\n");
printf("%02d:%02d:%02d\n", $hour, $min, $sec);

my $arr=["111", "222"];

print join(",", @{$arr}) . ',';

