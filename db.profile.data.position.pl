#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use CiomUtil;
use String::Buffer;


my $L1 = 1500;
my $L2 = 10;
my $L3 = 10;
my $L4 = 10;

my $fileCsv = "/tmp/position.csv";
my $buf = String::Buffer->new();
my $pid = 10;
my $ug = Data::UUID->new();	
my $hOut;

my $uuid1 = "";
my $uuid2 = "";
my $uuid3 = "";
my $uuid4 = "";

sub newLine($$) {
	my $current = shift;
	my $next = shift;

	$pid++;
	$buf->writeln("$pid,'$current','$next'");

	if ($pid % 100 == 0) {
		print $hOut $buf->flush();
	}
}

sub generateDataFile() {
	if (!open($hOut, '>', $fileCsv)) {
		output("Can not open $fileCsv\n");
		return 1;
	}

	my $head = "pid,currentPosition,nextPosition";
	$buf->writeln($head);
	for (my $m1 = 0; $m1 < $L1; $m1++) {
		$uuid1 = $ug->create_str();

		for (my $m2 = 0; $m2 < $L2; $m2++) {
			$uuid2 = $ug->create_str();
			newLine($uuid1, $uuid2);

			for (my $m3 = 0; $m3 < $L3; $m3++) {
				$uuid3 = $ug->create_str();
				newLine($uuid2, $uuid3);

				for (my $m4 = 0; $m4 < $L4; $m4++) {
					$uuid4 = $ug->create_str();
					newLine($uuid3, $uuid4);
				}								
			}
		}

	}

	print $hOut $buf->flush() || '';
	close($hOut);
}

sub importData2Db() {
	my $cmd = "perl -pE 's|#File#|$fileCsv|mg; s|#Table#|core_position_position_map|mg; s|#Column#|pid,currentPosition,nextPosition|mg;' mysql.load.data.from.file.tpl > _tmp_";
	system($cmd);
	system("mysql -h 172.17.128.231 -uroot -ppwdasdwx -e 'source ./_tmp_' yxt");
}

sub main() {
	if ($#ARGV == -1) {
		generateDataFile();
	} else {
		importData2Db();
	}
}

main();
