package ScmActor;

use strict;
use English;
use Data::Dumper;
use Clone 'clone';
use Hash::Merge::Simple qw(merge);
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
			"clean" => "%(prefix)s status %(name)s | grep '^?' | awk '{print \$2}' | xargs -I{} rm -rf '{}'",
            "version" => "%(prefix)s info %(name)s | grep -P '(Revision|Last Changed Rev)'| awk -F': ' '{print \$2}' | tr '\n', '.' | awk '{print \$1}' | awk -F'.' '{print \$1 \".\" \$2}'"
		},

		"git" => {
			"prefix" => "",
			"co" => "git clone -b %(branch)s --single-branch %(url)s %(name)s",
			"revert" => "(cd %(name)s; git checkout .)",
			"update" => "(cd %(name)s; git fetch)",
			"clean" => "(cd %(name)s; git clean -fd)",
			"version" => "(cd %(name)s; git rev-parse --short HEAD)"
		},

		"username" => $username,
		"password" => $password
	};

	bless $self, $class;
	return $self;
}

sub format() {
    my $self = shift;
    my $str = shift;
    
    if ($str eq '') {
        return $str;
    }
    return named_sprintf($str, $self->{namedHash});
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
        $repo->{url} =~ s|^(https?://)|$1$repo->{username}:$repo->{password}\@|m;
    }

    $self->{repo} = $repo;
    $self->{actor} = $self->{$repo->{type}};
    if ($self->{actor}->{prefix} ne '') {
        $self->{actor}->{prefix} = named_sprintf($self->{actor}->{prefix}, $repo);
    }
    $self->{namedHash} = merge $self->{actor}, $self->{repo};
}

sub co() {
    my $self = shift;
	my $actor = $self->{actor};
    return $self->format($actor->{co});
}

sub update() {
    my $self = shift;
	my $actor = $self->{actor};
	return [
		$self->format($actor->{clean}),
		$self->format($actor->{revert}),
    	$self->format($actor->{update}),
	];
}

sub version() {
    my $self = shift;
	my $actor = $self->{actor};
    return $self->format($actor->{version});
}


1;
__END__