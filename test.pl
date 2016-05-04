#!/usr/bin/perl -W
#
use Data::Dumper;
use JSON::Parse 'json_file_to_perl';
use JSON;
use Cwd;
use POSIX qw(strftime);

sub write_to_file {
	my $data  = shift;
	open my $fh, ">", "data_out.json";
	print $fh encode_json($data);
	close $fh;
}

#our $CiomData = json_file_to_perl("ciom.json");

#write_to_file($CiomData);

#my $CD = json_file_to_perl("data_out.json");

#print Dumper($CD);

#chdir("win");

#print getcwd();
#print "\n";

#chdir("..");

#print getcwd();
#print "\n";
$now_string = strftime "%Y-%m-%d %H:%M:%S", localtime;

print "$now_string";

