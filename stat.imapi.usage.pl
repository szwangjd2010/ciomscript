#!/usr/bin/perl -W
#

use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use String::Buffer;
use CiomUtil;
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";

my $ciomUtil = new CiomUtil(1);

my $aggregatedUsersUsage = {};
my $aggregatedUsersUsageResult = [];
my $usersUsage = {};

my $fileEventLog = "hz.qidaapi.evt.log";

sub initStatInfo($) {
	my $info = shift;
	$info->{total} = 0;
	$info->{android} = 0;
	$info->{iphone} = 0;
	$info->{macosx} = 0;
	$info->{windows} = 0;
}

sub plusStatInfo($$) {
	my $dest = shift;
	my $src = shift;
	$dest->{total} = $src->{total} ;
	$dest->{android} = $src->{android};
	$dest->{iphone} = $src->{iphone};
	$dest->{macosx} = $src->{macosx};
	$dest->{windows} = $src->{windows};
}

sub parseEventLog() {
	$usersUsage->{all} = {};
	initStatInfo($usersUsage->{all});

	my $h;
	if (!open($h, $fileEventLog)) {
		$ciomUtil->log("Can not open $fileEventLog!\n");
		return 1;
	}	

	my $line;
	my $device;
	my $uid;
	my $ua;

	while (1) {
		$line = <$h>;
		if (!defined($line)) {
			last;
		}

		$line =~ s|[\r\n]+||g;
		if ($line =~ m|/v1/orgs/71028353-7246-463f-ab12-995144fb4cb2/todo","","([^"]+).*"([\w-]+)","([\w-]+)"$|) {
			$ua = $1;
			$uid = $2;

			if ($ua =~ m|Android|) {
				$device = "android";
			} elsif ($ua =~ m|iPhone|) {
				$device = "iphone";
			} elsif ($ua =~ m|Mac OS X|) {
				$device = "macosx";
			} else {
				$device = "windows";
			}

			if (!defined($usersUsage->{$uid})) {
				$usersUsage->{$uid} = {};
				initStatInfo($usersUsage->{$uid});
			}
			$usersUsage->{$uid}->{$device}++;
			$usersUsage->{$uid}->{total}++;
			$usersUsage->{all}->{$device}++;
			$usersUsage->{all}->{total}++;			
		} else {
			next;
		}
	}

	close($h);	
}

sub percentageUsersUsage($$) {
	my $deviceTimes = shift;
	my $totalTimes = shift;

	return sprintf("%d(%.1f%%)",
		$deviceTimes,
		($deviceTimes + 0.00) / $totalTimes * 100.0
	);
}

sub humanlizeUsersUsage($) {
	my $info = shift;
	
	$info->{android} = percentageUsersUsage($info->{android}, $info->{total});
	$info->{iphone} = percentageUsersUsage($info->{iphone}, $info->{total});
	$info->{macosx} = percentageUsersUsage($info->{macosx}, $info->{total});
	$info->{windows} = percentageUsersUsage($info->{windows}, $info->{total});
}

sub addAggregatedUserUsageSummaryInfo() {
	$aggregatedUsersUsage->{all} = {};
	$aggregatedUsersUsage->{all}->{email} = "all users";
	$aggregatedUsersUsage->{all}->{name} = "all users";
	$aggregatedUsersUsage->{all}->{department} = "all departments";
	plusStatInfo($aggregatedUsersUsage->{all}, $usersUsage->{all});
	humanlizeUsersUsage($aggregatedUsersUsage->{all});
}

sub main() {
	parseEventLog();
	my $hUser;
	my $hImapiUsageResult;
	my $fileUser = "$ENV{CIOM_SCRIPT_HOME}/user.csv";
	if (!open($hUser, $fileUser)) {
		$ciomUtil->log("Can not open $fileUser!\n");
		return 1;
	}

	my $line;
	my $name;
	my $department;
	my $email;
	my $uid;	
	while (1) {
		$line = <$hUser>;
		if (!defined($line)) {
			last;
		}

		$line =~ s|[\r\n]+||g;
		if ($line =~ m|"(.*)","(.*)","(.*)","(.*)"|) {
			$name = $1;
			$department = $2;
			$email = $3;
			$uid = $4;

			if (!($name ne "" 
				&& $department ne ""
				&& $email ne ""
				&& $uid ne "")) {
				next;
			}
			if (!defined($aggregatedUsersUsage->{$uid})) {
				$aggregatedUsersUsage->{$uid} = {};
			}
			$aggregatedUsersUsage->{$uid}->{email} = $email;
			$aggregatedUsersUsage->{$uid}->{name} = $name;
			$aggregatedUsersUsage->{$uid}->{department} = $department;
			
			initStatInfo($aggregatedUsersUsage->{$uid});
			if (defined($usersUsage->{$uid})) {
				plusStatInfo($aggregatedUsersUsage->{$uid}, $usersUsage->{$uid});	
			}
		} else {
			next;
		}
	}

	addAggregatedUserUsageSummaryInfo();

#print Dumper($aggregatedUsersUsage);	
	close($hUser);

	sortByTimes();
	outputResult2CSV();
}

sub sortByTimes() {
	foreach my $uid ( 
		sort { $aggregatedUsersUsage->{$b}->{total} <=> $aggregatedUsersUsage->{$a}->{total} } 
		keys %{$aggregatedUsersUsage}
		) {
		if (!defined($aggregatedUsersUsage->{$uid}->{name}) || $aggregatedUsersUsage->{$uid}->{email} eq "") {
			next;
		}
		push(@{$aggregatedUsersUsageResult}, sprintf("%s,%s,%s,%s,%s,%s,%s,%s",
			$aggregatedUsersUsage->{$uid}->{name},
			$aggregatedUsersUsage->{$uid}->{department},
			$aggregatedUsersUsage->{$uid}->{email},
			$aggregatedUsersUsage->{$uid}->{total},
			$aggregatedUsersUsage->{$uid}->{android},
			$aggregatedUsersUsage->{$uid}->{iphone},
			$aggregatedUsersUsage->{$uid}->{macosx},
			$aggregatedUsersUsage->{$uid}->{windows}
		));
	}
}

sub outputResult2CSV() {
	my $buf = String::Buffer->new();
	my $cnt =$#{$aggregatedUsersUsageResult} +1;
	$buf->writeln(sprintf("%s,%s,%s,%s,%s,%s,%s,%s",
			"username",
			"department",
			"email",
			"total usage",
			"android usage",
			"iphone usage",
			"macosx usage",
			"windows usage"
	));

	for (my $i = 0; $i < $cnt; $i++) {
		$buf->writeln($aggregatedUsersUsageResult->[$i]);
	}

	$ciomUtil->writeToFile("usage.csv", $buf->flush() || '');
}

main();
