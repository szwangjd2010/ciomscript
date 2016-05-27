#!/usr/bin/perl -W
#
use Data::Dumper;
use bigint;
use JSON::Parse 'json_file_to_perl';
use JSON;
use Cwd;
use POSIX qw(strftime);
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Digest::xxHash qw[xxhash xxhash_hex];


sub write_to_file {
	my $data  = shift;
	open my $fh, ">", "data_out.json";
	print $fh encode_json($data);
	close $fh;
}
print hex("0x55b0f902776841c190374d51a9652acd"),"\n";

print xxhash_hex("55b0f902776841c190374d51a9652"),"\n";

