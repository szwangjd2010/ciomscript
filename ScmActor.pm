package ScmActor;

use strict;
use English;
use Data::Dumper;
use Clone 'clone';
use Text::Sprintf::Named qw(named_sprintf);


sub new() {
    my $class = shift;
    my $username = shift;
    my $password = shift;

	my $self = {
		"svn" => {
			"prefix" => "svn --non-interactive --username '%(username)s' --password '%(password)s'",
			"co" => "%(prefix)s co %(url)s %(name)s",
			"revert" => "%(prefix)s revert -R %(name)s",
			"update" => "%(prefix)s up %(name)s",
			"clearUnversioned" => "%(prefix)s status %(name)s | grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'",
			"version" => "%(prefix)s info %(name)s"
		},

		"git" => {
			"prefix" => "",
			"co" => "git clone -b %(branch)s --single-branch %(url)s %(name)s",
			"revert" => "(cd %(name)s; git checkout .)",
			"update" => "(cd %(name)s; git fetch)",
			"clearUnversioned" => "(cd %(name)s; git clean -fd)",
			"version" => "(cd %(name)s; git rev-parse --short HEAD)"
		},

		"username" => $username,
		"password" => $password,
	};

	bless $self, $class;
	return $self;
}

sub format() {
    my $self = shift;
    my $str = shift;
    my $hash = shift;

    if ($str eq '') {
        return $str;
    }
    return named_sprintf($str, $hash);
}

sub setRepo() {
    my $self = shift;
    my $repo = clone(shift);

    $repo->{username} = $repo->{username} || $self->{username};
    $repo->{password} = $repo->{password} || $self->{password};

    if (!defined($repo->{type})) {
        $repo->{type} = index($repo->{url}, 'git') > -1 ? 'git' : 'svn';
    }
    if ($repo->{type} eq 'git') {
        $repo->{branch} = $repo->{branch} || 'master';
        $repo->{url} =~ s|^(https?://)|\1$repo->{username}:$repo->{password}\@|m;
    }

    $self->{repo} = $repo;
    $self->{actor} = $self->{$repo->{type}};
    $self->{actor}->{prefix} = $self->format($self->{actor}->{prefix}, $repo);
}

sub co() {
    my $self = shift;
	my $actor = $self->{actor};
    my $repo = $self->{repo};
    return $self->format($actor->{co}, {
		prefix => $actor->{prefix},
        url => $repo->{url},
		branch => $repo->{branch},
		name => $repo->{name},
        username => $repo->{username},
        password => $repo->{password}
    });
}

sub update() {
    my $self = shift;
	my $actor = $self->{actor};
    my $repo = $self->{repo};
	return [
		$self->format($actor->{clearUnversioned}, {
			prefix => $actor->{prefix},
			name => $repo->{name}
    	}),
		$self->format($actor->{revert}, {
			prefix => $actor->{prefix},
			name => $repo->{name}
    	}),
    	$self->format($actor->{update}, {
			prefix => $actor->{prefix},
			name => $repo->{name}
    	}),
	];
}

sub version() {
    my $self = shift;
	my $actor = $self->{actor};
    my $repo = $self->{repo};
    return $self->format($actor->{version}, {
		prefix => $actor->{prefix},
		name => $repo->{name}
    });
}


1;
__END__