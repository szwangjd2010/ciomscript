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

my $repos = [
{
    name => 'lecaiapi',
    url => "http://172.17.128.21:9000/svn/bigdata/trunk/datav_dashboardapi"
},
{
    name => 'goldbrush',
    url => "https://gitlab.yunxuetang.com.cn/pub/goldrush.git",
    branch => 'b1.0'
}

];

my $scm = new ScmActor('jenkins', 'pwdasdwx');
foreach my $repo (@{$repos}) {
    $scm->setRepo( $repo);
    #print $scm->co();
    #print $scm->version();
    #print Dumper $scm->update();
}

my $arr = [
"aaaa",
"bbbb"
];

map {
    $_ = $_ . " " . $_;
} @{$arr};

print Dumper($arr);

foreach my $a (@{$arr}) {
    $a = $a . '---';
}
print Dumper($arr);

