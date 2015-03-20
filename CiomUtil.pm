package CiomUtil;


use strict;
use English;
use Data::Dumper;

sub new() {
    my $pkg = shift;
	my $runMode = shift;
	
	my $self = {
		RunMode => $runMode,
		Log => '/tmp/_ciom.log',
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

sub log() {
	my $self = shift;
	my $cmd = shift;
	system("printf \"$cmd\" | tee -a $self->{Log}");
}

sub exec() {
	my $self = shift;
	my $cmd = shift;
	
	$self->log($cmd);
	if ($self->{RunMode} == 1) {
		system("$cmd");
	}
}

sub remoteExec() {
	my $self = shift;
	my $host = shift;
	my $port = shift;
	my $cmd = shift;
	
	$self->exec("ssh -p $port root\@$host \"$cmd\"");
}

sub write() {
	my $self = shift;
	my $file = shift;
	my $content = shift;
	my $h;
	if (!open($h, '>', $file)) {
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

1;
__END__