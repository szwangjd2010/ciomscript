drop table if exist #TABLE_NAME#;
create table #TABLE_NAME# (
#FIELDS#
) row format delimited fields terminated by '\t';

