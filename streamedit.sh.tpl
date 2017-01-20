%% FOREACH file IN files.keys
%%   FOREACH item IN files.$file
%%     singleFlag = item.single == 1 ? " -0" : ""
perl -CSDL -i[% singleFlag %] -pE 's|[% item.re %]|[% item.to %]|mg' [% file %]
%%   END
%% END
