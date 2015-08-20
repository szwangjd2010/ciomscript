#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use String::Buffer;

my $gLogFile = $ARGV[0];
my $gApisInfo = {};
my $gCounter = 0;
my $gCost = 0;
my $gApisSortedByCost = [];
my $gApisSortedByCounter = [];
my $gCostInfoFile = "cost.info";
my $gCounterInfoFile = "counter.info";

sub add2Global($) {
	my $apiInfo = shift;
	$gCounter++;
	$gCost += $apiInfo->{cost};
}

sub initApiInfoInGApisInfo($) {
	my $apiInfo = shift;

	my $cost = $apiInfo->{cost};
	$gApisInfo->{$apiInfo->{api}} = {
		counter => 1,
		max => $cost,
		min => $cost,
		avg => $cost,
		sum => $cost,
		fun => $apiInfo->{fun}
	};
}

sub plusApiInfo2GApisInfo($) {
	my $apiInfo = shift;

	my $info = $gApisInfo->{$apiInfo->{api}};
	my $cost = $apiInfo->{cost};
	$info->{counter} += 1;
	$info->{max} = $info->{max} > $cost ? $info->{max} : $cost;
	$info->{min} = $info->{min} < $cost ? $info->{min} : $cost;
	$info->{sum} += $cost;
	$info->{avg} = $info->{sum} / $info->{counter};
}

sub sortByCost() {
	foreach my $api ( 
		sort { $gApisInfo->{$b}->{avg} <=> $gApisInfo->{$a}->{avg} } 
		keys %{$gApisInfo}
		) {
		push(@{$gApisSortedByCost}, $api);
		#print "$api $gApisInfo->{$api}->{avg} \n";
	}
}

sub sortByCounter() {
	foreach my $api ( 
		sort { $gApisInfo->{$b}->{counter} <=> $gApisInfo->{$a}->{counter} } 
		keys %{$gApisInfo}
		) {
		push(@{$gApisSortedByCounter}, $api);
		#print "$api $gApisInfo->{$api}->{counter} \n";
	}
}

sub outGlobalInfo($) {
	my $h = shift;
	my $ginfo = sprintf("total executed api counter: %d, total api executed time: %.2f min(s)\n\n",
		$gCounter,
		$gCost / (1000 * 60)
	);

	print $h $ginfo;
}

sub out($) {
	my $str = shift;
	print $str . "\n";
}

sub outApisCostInfo() {
	my $h;
    if (!open($h, '>', $gCostInfoFile)) {
    	print("Can not open $gCostInfoFile \n");
    	return;
    }

    outGlobalInfo($h);
    print $h "average (max, min) api.executed.counter api\n";
	my $buf = String::Buffer->new();
	my $cnt = $#{$gApisSortedByCost} + 1;
	for (my $i = 0; $i < $cnt; $i++) {
		my $api = $gApisSortedByCost->[$i];
		my $apiInfo = $gApisInfo->{$api};
		$buf->writeln(sprintf("%4dms (%4dms, %4dms) %8d  %s",
			$apiInfo->{avg},
			$apiInfo->{max},
			$apiInfo->{min},
			$apiInfo->{counter},
			$api
		));

		if ($i % 1000 == 0) {
			print $h $buf->flush() || '';
		}
	}
	print $h $buf->flush() || '';
	close($h);
}

sub outApisCounterInfo() {
	my $h;
    if (!open($h, '>', $gCounterInfoFile)) {
    	print("Can not open $gCounterInfoFile \n");
    	return;
    }

    outGlobalInfo($h);
    print $h "api.executed.counter api\n";
	my $buf = String::Buffer->new();	
	my $cnt = $#{$gApisSortedByCounter} + 1;

	for (my $i = 0; $i < $cnt; $i++) {
		my $api = $gApisSortedByCounter->[$i];
		my $apiInfo = $gApisInfo->{$api};
		$buf->writeln(sprintf("%8d %s",
			$apiInfo->{counter},
			$api
		));

		if ($i % 1000 == 0) {
			print $h $buf->flush() || '';
		}
	}
	print $h $buf->flush() || '';
	close($h);
}


sub main() {
	my $h;
	if (!open($h, $gLogFile)) {
		output("Can not open $gLogFile!\n");
		return 1;
	}

	my $apiInfo = {
		dt => 0,
		api => '',
		fun => '',
		cost => 0
	};

	my $line;
	while (1) {
		$line = <$h>;
		if (!defined($line)) {
			last;
		}

		if ($line =~ m|(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) ([\w/-]+) (\w+) (\d+)ms|) {
			$apiInfo->{dt} = $1;
			$apiInfo->{api} = $2;
			$apiInfo->{fun} = $3;
			$apiInfo->{cost} = $4;
		} else {
			next;
		}

		#uuid 3698ad58-ebbf-4aec-8bec-484fa4ca7528 ->#uuid#
		$apiInfo->{api} =~ s/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/%uuid%/g;
		if (!defined($gApisInfo->{$apiInfo->{api}})) {
			initApiInfoInGApisInfo($apiInfo);
		} else {
			plusApiInfo2GApisInfo($apiInfo);
		}

		add2Global($apiInfo);
	}
	close($h);

	sortByCost();
	sortByCounter();

	outApisCostInfo();
	outApisCounterInfo();
}

main();