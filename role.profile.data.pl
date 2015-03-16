#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use BashUtil;

sub main();

my $bashUtil = new BashUtil(1);
my $SqlTpl = "insert into core_position_position_map (pid, currentPosition, nextPosition) values (#pid#, '#currentPosition#', '#nextPosition#');";
my $L1 = 1500;
my $L2 = 10;
my $L3 = 10;
my $L4 = 10;

sub main() {
	my $ug = Data::UUID->new();
	my $pid = 10;
	my $sql = "";
	my $uuid1 = "";
	my $uuid2 = "";
	my $uuid3 = "";
	my $uuid4 = "";
	for (my $m1 = 0; $m1 < $L1; $m1++) {
		$uuid1 = $ug->create_str();

		for (my $m2 = 0; $m2 < $L2; $m2++) {
			$pid++;
			$uuid2 = $ug->create_str();
			$sql = $SqlTpl;
			$sql =~ s/#pid#/$pid/;
			$sql =~ s/#currentPosition#/$uuid1/;
			$sql =~ s/#nextPosition#/$uuid2/;
			system("echo \"$sql\" >> /tmp/out.sql");

			for (my $m3 = 0; $m3 < $L3; $m3++) {
				$pid++;
				$uuid3 = $ug->create_str();

				$sql = $SqlTpl;
				$sql =~ s/#pid#/$pid/;
				$sql =~ s/#currentPosition#/$uuid2/;
				$sql =~ s/#nextPosition#/$uuid3/;
				system("echo \"$sql\" >> /tmp/out.sql");

				for (my $m4 = 0; $m4 < $L4; $m4++) {
					$pid++;
					$uuid4 = $ug->create_str();

					$sql = $SqlTpl;
					$sql =~ s/#pid#/$pid/;
					$sql =~ s/#currentPosition#/$uuid3/;
					$sql =~ s/#nextPosition#/$uuid4/;
					system("echo \"$sql\" >> /tmp/out.sql");				
				}								
			}
		}

	}
}

main()
