#!/usr/bin/perl -W
#
package T123;
use strict;
use warnings;
use Template;
use Clone 'clone';
use Hash::Merge::Simple qw( merge );
use Data::Dumper;
use ScmActor;
use Text::Sprintf::Named qw(named_sprintf);
use Template;
use File::Path qw(make_path remove_tree);

#make_path("/tmp/1111/2222/3333") || die "error in creating dir";


my %h1 = (a => 'a', b => 'b');
print Dumper(%ENV);
print $h1{a} . "\n";
print $h1{b} . "\n";

my $RuntimeContext = "JENKINS";
#$ENV{DeployMode} = "Rollback";
$ENV{RollbackTo} = "2";

my $DeployMode = (sub {
    my $mode = "deploy";
    if ($RuntimeContext eq "JENKINS" && defined($ENV{DeployMode})) {
        $mode = $ENV{DeployMode};
    }
    if ($RuntimeContext eq "CLI" && $#ARGV + 1 > 3) {
        $mode = $ARGV[3];
    }
    return lc($mode);
})->();


my $RollbackTo = (sub {
    if ($DeployMode eq "deploy") {
        return "";
    }
    my $to = "";
    if ($RuntimeContext eq "JENKINS" && defined($ENV{RollbackTo})) {
        $to = $ENV{RollbackTo};
    }
    if ($RuntimeContext eq "CLI" && $#ARGV + 1 > 4) {
        $to = $ARGV[4];
    }
    return lc($to);
})->();

print $DeployMode ."\n";
print $RollbackTo ."\n";
