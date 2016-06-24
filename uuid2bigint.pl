#!/usr/bin/perl -W
# 

use Data::Dumper;
use bigint;
use CiomUtil;
use String::Buffer;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $CSV_FILE=$ARGV[0];
my $OUT_FILE="$CSV_FILE.bigint";
my $hOut;
my $sb = String::Buffer->new();
my $ciomUtil = new CiomUtil();

sub openOut() {
	if (!open($hOut, '>', $OUT_FILE)) {
		$ciomUtil->log("Can not open $OUT_FILE!\n");
		return 1;
	}		
}

sub flush2OUt() {
	print $hOut $sb->flush() || '';
}

sub closeOut() {
	close($hOut);
}

sub clean() {
	system("perl -i -pE 's/-//g' $CSV_FILE");
}

sub main() {
	clean();

	openOut();
	my $h;
	if (!open($h, $CSV_FILE)) {
		$ciomUtil->log("Can not open $CSV_FILE!\n");
		return 1;
	}	

	my $line;
	my $counter = 0;
	while (1) {
		$counter++;
		if ($counter == 1) {
			next;
		}

		$line = <$h>;
		if (!defined($line)) {
			last;
		}

		$line =~ s|[\r\n]+||g;
		if ($line =~ m|^(\w+),(\w+),(\w+),(\w+),(\w+)$|) {
			$sb->writeln(hex("0x$1") . "," . hex("0x$2") . "," . hex("0x$3") . "," . hex("0x$4") . "," . hex("0x$5"));
		}

		if ($counter % 10000 == 0) {
			flush2OUt();
		}
	}
	flush2OUt();
	closeOut();

	close($h);	
}

main();
