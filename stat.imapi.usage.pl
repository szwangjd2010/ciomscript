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
my $users = {};
my $usersUsage = {};
my $usersUsageResult = [];

sub main() {
	my $hUser;
	my $hImapiUsageResult;
	my $fileUser = "$ENV{CIOM_SCRIPT_HOME}/user.csv";
	my $fileImapiUsageResult = 'hz.imapi.todo.userid.times.result';
	if (!open($hUser, $fileUser)) {
		$ciomUtil->log("Can not open $fileUser!\n");
		return 1;
	}
	if (!open($hImapiUsageResult, $fileImapiUsageResult)) {
		$ciomUtil->log("Can not open $fileImapiUsageResult!\n");
		return 1;
	}	
	
	my $line;
	my $name;
	my $department;
	my $email;
	my $uid;	
	my $times;
	while (1) {
		$line = <$hUser>;
		if (!defined($line)) {
			last;
		}

		$line =~ s|[\r\n]+||g;
		if ($line =~ m|(.*),(.*),(.*),(.*)|) {
			$name = $1;
			$department = $2;
			$email = $3;
			$uid = $4;

			if (!defined($users->{$uid})) {
				$users->{$uid} = {};
			}
			$users->{$uid}->{email} = $email;
			$users->{$uid}->{name} = $name;
			$users->{$uid}->{department} = $department;
		} else {
			next;
		}
	}

	
	while (1) {
		$line = <$hImapiUsageResult>;
		if (!defined($line)) {
			last;
		}

		$line =~ s|[\r\n]+||g;
		if ($line =~ m|\s+(\d+)\s([\w-]+)|) {
			$times = $1;
			$uid = $2;
			if (0 && $uid eq '44240668-f3c9-413c-a88e-322eebb8efa3') {
				$times = 198;
			}
	
			if (!defined($usersUsage->{$uid})) {
				$usersUsage->{$uid} = {};
			}
			$usersUsage->{$uid}->{times} = $times;
			$usersUsage->{$uid}->{email} = $users->{$uid}->{email};
			$usersUsage->{$uid}->{name} = $users->{$uid}->{name};
			$usersUsage->{$uid}->{department} = $users->{$uid}->{department};
	
		} else {
			next;
		}		
	}
#print Dumper($usersUsage);	
	close($hUser);
	close($hImapiUsageResult);


	sortByTimes();
	outputResult2CSV();
}

sub sortByTimes() {
	foreach my $uid ( 
		sort { $usersUsage->{$b}->{times} <=> $usersUsage->{$a}->{times} } 
		keys %{$usersUsage}
		) {
		if (!defined($usersUsage->{$uid}->{name}) || $usersUsage->{$uid}->{email} eq "") {
			next;
		}
		push(@{$usersUsageResult}, sprintf('%s,%s,%s,%s,%s',
			$usersUsage->{$uid}->{times},
			$usersUsage->{$uid}->{name},
			$usersUsage->{$uid}->{department},
			$usersUsage->{$uid}->{email},
			$uid
		));
	}
}

sub outputResult2CSV() {
	my $buf = String::Buffer->new();
	my $cnt =$#{$usersUsageResult} +1;
	for (my $i = 0; $i < $cnt; $i++) {
		$buf->writeln($usersUsageResult->[$i]);
	}

	$ciomUtil->writeToFile("usage.csv", $buf->flush() || '');
}

main();
