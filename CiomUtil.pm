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

sub _run() {
	my $self = shift;
	my $cmd = shift;
	my $log = shift;
	
	if ($log == 1) {
		$self->log($cmd);
	}
	if ($self->{RunMode} == 1) {
		system($cmd);
	}
}

sub exec() {
	my $self = shift;
	my $cmd = shift;
	my $log = shift || 1;

	if (ref($cmd) eq 'ARRAY') {
		if ($#{$cmd} == -1) {
			return;
		}
		my $jointCmds = "(" . join("; ", @{$cmd}) . ")";
		$self->_run($jointCmds, $log);
	} else {
		$self->_run($cmd, $log);
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
		if ($#{$cmd} == -1) {
			return;
		}
		my $jointCmds = "(" . join("; ", @{$cmd}) . ")";
		$self->exec("ssh -p $port $user\@$host '$jointCmds'");
	} else {
		$self->exec("ssh -p $port $user\@$host '$cmd'");
	}
}

sub isEqual() {
	my $self = shift;
	my $left = shift;
	my $right = shift;

	return defined($left) && $left eq $right;
}

sub isNotEmpty() {
	my $self = shift;
	my $v = shift;

	return defined($v) && $v ne ''; 
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

sub getJenkinsCliBase() {
	my $self = shift;

	return "java -jar /var/lib/jenkins/jenkins-cli.jar"
		. " -s http://localhost:8080/"
		. " -i /var/lib/jenkins/.ssh/id_rsa";
}

sub getJenkinsJobCli {
	my ($self, $job, $hashParams) = @_;

	return sprintf("%s %s %s %s",
		$self->getJenkinsCliBase(),
		"build",
		$job,
		$self->_constructJenkinsJobParameters($hashParams)
	);
}

sub runJenkinsJob {
	my ($self, $job, $hashParams) = @_;
	$self->exec($self->getJenkinsJobCli($job, $hashParams));
}

sub reloadJenkinsJob() {
	my $self = shift;
	my $job = shift;

	my $cmd = sprintf("%s %s %s",
		$self->getJenkinsCliBase(),
		"reload-job",
		$job
	);
	$self->exec($cmd);
}

sub getJenkinsJob() {
	my $self = shift;
	my $job = shift;

	my $cmd = sprintf("%s %s %s",
		$self->getJenkinsCliBase(),
		"get-job",
		$job
	);
	$self->exec($cmd);
}

sub prettyPath() {
	my $self = shift;
	my $path = shift;
	$path =~ s|/{1,}|/|g;
	return $path;
}

sub removeLastSlashForUrl() {
	my $self = shift;
	my $url = shift;
	my $lastIndex = rindex($url,"/");
	my $length = length($url);  
    
	if ($lastIndex == $length-1) {
        my $newUrl = substr($url,0,$length-1);
        return $newUrl;
	}
	else{
		return $url;
	}

}

sub getTimestamp() {
	my $self = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	return sprintf("%04d%02d%02d+%02d%02d%02d", 
		$year + 1900,
		$mon + 1,
		$mday,
		$hour,
		$min,
		$sec);
}

sub getDatestamp() {
	my $self = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	return sprintf("%04d%02d%02d", 
		$year + 1900,
		$mon + 1,
		$mday);
}


1;
__END__