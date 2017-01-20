#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';

my $file = '/opt/ciom/ciomscript/streamedit.sh.tpl';
my $template = Template->new({    PRE_CHOMP  => 1,
    POST_CHOMP => 0,
    ABSOLUTE => 1
});


my $streameditItems = {
        "datav_dashboard/src/config/api.js" => [
            {
                "re" => "(api_rootUrl = ').*(';)",
                "to" => "\${1}http://datavdashboard.yunxuetang.com.cn/datavdashboardapi/v1\${2}",
                "single" => "2"
            }
        ],

        "datav_dashboard/src/config/setting.js" => [
            {
                "re" => "(showProvinces: )(true|false)",
                "to" => "\${1}: false"
            },
            {
                "re" => "(maxUsers: )\\d+",
                "to" => "\${1}: 50"
            }
        ]
    };

my $ca = clone($streameditItems);
my $ss = {"aa" => "aa", "bb" => 'bb'    };
#my $ss=[1,2];
my $files = {files => $streameditItems };


print '(' . join(';', @{["111", '222']}) . ')';