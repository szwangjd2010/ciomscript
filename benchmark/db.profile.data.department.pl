#!/usr/bin/perl -W
# 
#
use strict;
use English;
use Data::Dumper;
use Data::UUID;
use CiomUtil;
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

my $ciomUtil = new CiomUtil();

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

sub generateDataFile() {
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

sub importData2Db() {
	system("perl -pE 's|#File#|$fileCsv|mg; s|#Table#|core_department|mg; s|#Column#|orgId,parentId,pid|mg;' mysql.load.data.from.file.tpl > _tmp_");
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
