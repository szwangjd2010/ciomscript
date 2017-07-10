package ScmUtil;

use strict;
use English;
use Data::Dumper;
use Text::Sprintf::Named qw(named_sprintf);


sub new() {
    my $class = shift;
    my $username = shift;
    my $password = shift;
    my $repo = shift;

	my $self = {
		"svn": {
			"prefix" => "svn --non-interactive --username '%(username)' --password '%(password)'",
			"co" => "%(prefix) co %(url) %(name)",
			"revert" => "%(prefix) revert -R %(name)",
			"update" => "%(prefix) up %(name)",
			"clearUnversioned" => "%(prefix) status $(name) | grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'",
			"version" => "%(prefix) info $(name)"
		},

		"git": {
			"prefix" => "",
			"co" => "git --single-branch clone %(url)",
			"revert" => "(cd %(name); git checkout .)",
			"update" => "(cd %(name); git fetch)",
			"clearUnversioned" => "(cd %(name); git clean -fd)",
			"version" => "(cd %(name); git rev-parse --short HEAD)"
		},

		"username" => $username,
		"password" => $password,
		"type": "svn",
	};

	bless $self, $class;
	return $self;
}

sub co() {
	my $scm = $self->{$self->{type}};
    return named_sprintf($scm->{co}, {
		prefix => $scm->{prefix},
		url => $self->{repo}->{url},
		name => $self->{repo}->{name}
    });
}

sub update() {
	my $scm = $self->{$self->{type}};
	return [
		named_sprintf($scm->{clearUnversioned}, {
			prefix => $scm->{prefix},
			name => $self->{repo}->{name}
    	}),
		named_sprintf($scm->{revert}, {
			prefix => $scm->{prefix},
			name => $self->{repo}->{name}
    	}),
    	named_sprintf($scm->{update}, {
			prefix => $scm->{prefix},
			name => $self->{repo}->{name}
    	}),
	];
}

sub version() {
	my $scm = $self->{$self->{type}};
    return named_sprintf($scm->{version}, {
		prefix => $scm->{prefix},
		name => $self->{repo}->{name}
    });
}


1;
__END__