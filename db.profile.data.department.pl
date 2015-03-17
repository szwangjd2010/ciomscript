#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use BashUtil;
use String::Buffer;


my $L1 = 10000;
my $L2 = 10;
my $L3 = 5;
my $L4 = 5;

my $fileCsv = "/tmp/department.csv";
my $buf = String::Buffer->new();
my $idx = 0;
my $ug = Data::UUID->new();	
my $hOut;

my $uuid1 = "";
my $uuid2 = "";
my $uuid3 = "";
my $uuid4 = "";

sub newLine($$$) {
	my $orgId = shift;
	my $parentId = shift;
	my $pid = shift;

	$idx++;
	$buf->writeln("$orgId,'$parentId','$pid'");

	if ($idx % 100 == 0) {
		print $hOut $buf->flush();
	}
}

sub main() {
	if (!open($hOut, '>', $fileCsv)) {
		output("Can not open $fileCsv\n");
		return 1;
	}

	my $head = "orgId,parentId,pid";
	$buf->writeln($head);
	for (my $m1 = 0; $m1 < $L1; $m1++) {
		$uuid1 = $ug->create_str();

		for (my $m2 = 0; $m2 < $L2; $m2++) {
			$uuid2 = $ug->create_str();

			for (my $m3 = 0; $m3 < $L3; $m3++) {
				$uuid3 = $ug->create_str();
				newLine($uuid1, $uuid2, $uuid3);

				for (my $m4 = 0; $m4 < $L4; $m4++) {
					$uuid4 = $ug->create_str();
					newLine($uuid1, $uuid3, $uuid4);					
				}								
			}
		}

	}

	print $hOut $buf->flush() || '';
	close($hOut);
}

main();
