package CiomUtil;


use strict;
use English;
use Data::Dumper;

sub new() {
    my $pkg = shift;
	my $runMode = shift;
	
	my $self = {
		RunMode => $runMode,
		Log => $ENV{CIOM_LOG_FILE},
		DebugHost => '192.168.0.125',
		DebugPort => '22'
	};
	bless $self, $pkg;
	return $self;
}

sub setRunMode() {
	my $self = shift;
	$self->{RunMode} = shift;
}

sub output() {
	my $self = shift;
	my $cmd = shift;
	
	my $out = "$cmd\n";
	print $out;
}

sub log() {
	my $self = shift;
	my $cmd = shift;
	
	my $out = "$cmd\n";
	print $out;
	$self->appendToFile($self->{Log}, $out);
}

sub exec() {
	my $self = shift;
	my $cmd = shift;
	my $log = shift || 1;
	
	if ($log == 1) {
		$self->log($cmd);
	}

	if ($self->{RunMode} == 1) {
		system($cmd);
	}
}

sub execNotLogCmd() {
	my $self = shift;
	my $cmd = shift;
	$self->exec($cmd, 0);
}

sub execWithReturn() {
	my $self = shift;
	my $cmd = shift;
	my $mode = shift || 0;
	
	$self->log($cmd);
	if ($self->{RunMode} == 1 || $mode == 1) {
		readpipe($cmd);
	}
}

sub remoteExec() {
	my $self = shift;
	my $info = shift;
	my $host = $info->{host};
	my $port = $info->{port} || 22;
	my $user = $info->{user} || 'root';
	my $cmd = $info->{cmd};
	
	if (ref($cmd) eq 'ARRAY') {
		for (my $i = 0; $i <= $#{$cmd}; $i++) {
			my $idxCmd = $cmd->[$i];
			$self->exec("ssh -p $port $user\@$host '$idxCmd'");
		}
	} else {
		$self->exec("ssh -p $port $user\@$host '$cmd'");
	}
}

sub upload() {
	my $self = shift;
	my $local = shift;
	my $remote = shift;

	$self->exec("scp $local root\@$remote/");
}

sub writeToFile() {
	my $self = shift;
	my $file = shift;
	my $content = shift;
	my $h;
	if (!open($h, '>:utf8', $file)) {
		print "open $file failed!\n";
		return -1
	}
	print $h $content;
	close($h);
	
	return 0;
}

sub appendToFile() {
	my $self = shift;
	my $file = shift;
	my $content = shift;
	my $h;
	if (!open($h, '>>:utf8', $file)) {
		print "open $file failed!\n";
		return -1
	}

	print $h $content;
	close($h);
	
	return 0;
}

sub _constructJenkinsJobParameters() {
	my $self = shift;
	my $hashParams = shift;
	my $str = "";
	while ( my ($key, $value) = each(%{$hashParams}) ) {
		$str .= " -p $key='$value'";
	}
	
	return $str;
}

sub constructJenkinsJobCmd() {
	my $self = shift;
	my $job = shift;
	my $hashParams = shift;

	my $CmdPrefix = "java -jar /var/lib/jenkins/jenkins-cli.jar"
		. " -s http://172.17.128.240:8080/"
		. " -i /var/lib/jenkins/.ssh/id_rsa"
		. " build $job"
		. " -s -v";
		
	return $CmdPrefix . $self->_constructJenkinsJobParameters($hashParams);
}

sub runJenkinsJob() {
	my $self = shift;
	my $job = shift;
	my $hashParams = shift;

	my $cmd = $self->constructJenkinsJobCmd($job, $hashParams);
	$self->exec($cmd);
}

sub prettyPath() {
	my $self = shift;
	my $path = shift;
	$path =~ s|/{1,}|/|g;
	return $path;
}

sub getTimestamp() {
	my $self = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	return "$year$mon$mday+$hour$min$sec";
}

sub getDatestamp() {
	my $self = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	return "$year$mon$mday";
}


1;
__END__