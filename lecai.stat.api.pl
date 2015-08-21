#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use CiomUtil;

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
my $ciomUtil = new CiomUtil(1);

sub main() {
	for my $name (keys %{$Apps}) {
		if ($name ne "lecai.api") {
			next;
		}

		my $appDailyLogLocation = $TplAppDailyLogLocation;
		$appDailyLogLocation =~ s/#AppName#/$name/;
		$appDailyLogLocation =~ s/#Date#/$statedDate/;
		my $appTimelogListFile = "$appDailyLogLocation/$name.timelog.list";
		system("find $appDailyLogLocation -name time.$statedDate.log > $appTimelogListFile");

		#my $h;
		open(my $h, "<", "$appTimelogListFile") or die("Cannot open $appTimelogListFile!\n");
		my @arrTimelogFiles = <$h>;
		close($h);

		my $cnt = $#arrTimelogFiles + 1;
		for (my $i = 0; $i < $cnt; $i++) {
			my $logfile = $arrTimelogFiles[$i];
			$logfile =~ s/\n//g;
			$logfile =~ m|\d{8}/(.+)/logs/|;
			my $tomcatId = $1;
			$tomcatId =~ s|/|+|g;

			$ciomUtil->exec("perl stat.api.pl $logfile $appDailyLogLocation $tomcatId");
		}

		my $allInOneLogFile = "$appDailyLogLocation/time.$statedDate.all-instances.log";
		$ciomUtil->exec("perl stat.api.pl $allInOneLogFile $appDailyLogLocation all-instances");
		
		my $instanceSimpleSumFile = "$appDailyLogLocation/tomcats.instance.simple.sum";
		$ciomUtil->exec("cat $appDailyLogLocation/*tomcat7*simple.sum | sort > $instanceSimpleSumFile");
		$ciomUtil->exec("sed -i \"1 r $instanceSimpleSumFile\" $appDailyLogLocation/all-instances+cost.txt");
		$ciomUtil->exec("sed -i \"1 r $instanceSimpleSumFile\" $appDailyLogLocation/all-instances+counter.txt");
	}	
}

main();
