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

my $Tpl;


my $h1 = {
    '/opt/ins1' => {
        pActive => "hello",
        port => "8080"
    },
    "hello" => "world"
};

sub initTpl() {
    $Tpl = Template->new({
        ABSOLUTE => 1,
        TAG_STYLE => 'outline',
        PRE_CHOMP  => 0,
        POST_CHOMP => 0
    }); 
}
sub processTemplate {
    my ($in, $data, $out) = @_;
    $Tpl->process($in, $data, $out) 
        || die "Template process failed: ", $Tpl->error(), "\n";    
}


#my $cmd = "[% root.item('hello') %]";
my $cmd = "[% root.item('/opt/ins1').pActive %]";

my $out = "";

initTpl();
processTemplate(\$cmd, {root => $h1}, \$out);

print $out . "\n";

