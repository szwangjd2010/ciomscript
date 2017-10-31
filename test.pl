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

sub main() {
     initTpl();
     my $out = "";
     processTemplate(\"[% root.a + root.b %]", {root => {a => 11, b => 1}}, $out);
     print $out . "\n";
}


main()
