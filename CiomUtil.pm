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
	system("echo $cmd | tee -a $self->{Log}");
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

1;
__END__