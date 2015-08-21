#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;

my $Apps = {
	'lecai.api' => [
		'10.10.73.235',
		'10.10.76.73',
		'10.10.75.138'
	],
	'component.api' => [
		'10.10.106.125'
	],
	'mall.api' => [
		'10.10.110.226'
	]
};

my $statedDate = $ARGV[0];
my $TplAppDailyLogLocation = "/sdb/ciompub/#AppName#/#Date#";

sub main() {
	for my $name (keys %{$Apps}) {
		if ($name ne "lecai.api") {
			next;
		}

		my $appDailyLogLocation = $TplAppDailyLogLocation;
		$appDailyLogLocation =~ s/#AppName#/$name/;
		$appDailyLogLocation =~ s/#Date#/$statedDate/;
		system("find $appDailyLogLocation -name 'time.$statedDate.log > $name.timelog.list");

		my @arrTimelogFiles = <$name.timelog.list>;

		my $cnt = $#arrTimelogFiles + 1;
		for (my $i = 0; $i < $cnt; $++) {
			my $logfile = $arrTimelogFiles[$i];
			$logfile =~ m|\d{8}/(.+)/logs/|;
			my $tomcatId = $1;
			$tomcatId =~ s|/|+|g;
			system("perl stat.api.pl $logfile $appDailyLogLocation $tomcatId");
		}

		my $allInOneLogFile = "$appDailyLogLocation/$name.$statedDate.all-instances.log";

		system("perl stat.api.pl $allInOneLogFile $appDailyLogLocation all-instances");
	}	
}

main();
