#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use BashUtil;
use String::Buffer;

sub main();
sub newLine($);

my $bashUtil = new BashUtil(1);
my $L1 = 1500;
my $L2 = 10;
my $L3 = 10;
my $L4 = 10;

my $buf;
my $pid;
my $hOut;
my $ug;

sub newLine($) {
	$pid++;
	my $current = shift;
	my $next = $ug->create_str();
	$buf->writeln("$pid,\"$current\",\"$next\"");

	if ($pid % 100 == 0) {
		print $hOut $buf->flush();
	}

	return $next;
}

sub main() {
	$buf = String::Buffer->new();
	$pid = 10;
	if (!open($hOut, '>', "/tmp/out.sql")) {
		output("Can not open /tmp/out.sql\n");
		return 1;
	}

	$ug = Data::UUID->new();
	my $head = "pid,currentPosition,nextPosition";
	
	my $uuid1 = "";
	my $uuid2 = "";
	my $uuid3 = "";
	my $uuid4 = "";

	$buf->writeln($head);
	for (my $m1 = 0; $m1 < $L1; $m1++) {
		$uuid1 = $ug->create_str();

		for (my $m2 = 0; $m2 < $L2; $m2++) {
			$uuid2 = newLine($uuid1);

			for (my $m3 = 0; $m3 < $L3; $m3++) {
				$uuid3 = newLine($uuid2);

				for (my $m4 = 0; $m4 < $L4; $m4++) {
					newLine($uuid3);						
				}								
			}
		}

	}

	print $hOut $buf->flush();
	close($hOut);
}

main()
