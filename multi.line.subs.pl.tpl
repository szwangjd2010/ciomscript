#!/usr/bin/perl -p
# perl -i -pe0 's///smg'
#
use strict;
use warnings;

BEGIN {
	undef $/;
}

s/#Pattern#/#To#/smg;