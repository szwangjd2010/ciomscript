#!/usr/bin/perl -W
#
use strict;
use warnings;
use Template;
use Clone 'clone';

my $file = 'streamedit.sh.tpl';
my $template = Template->new({    PRE_CHOMP  => 0,
    POST_CHOMP => 0,
    TAG_STYLE => 'outline',
});


my $streameditItems = {
        "datav_dashboard/src/config/api.js" => [
            {
                "re" => "(api_rootUrl = ').*(';)",
                "to" => "\${1}http://datavdashboard.yunxuetang.com.cn/datavdashboardapi/v1\${2}",
                "single" => "1"
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


my $files = {files => $streameditItems };


$template->process("streamedit.sh.tpl", {files => $streameditItems })
        || die "Template process failed: ", $template->error(), "\n";