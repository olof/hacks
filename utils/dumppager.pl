#!/usr/bin/perl
# Copyright 2011, Olof Johansson <olof@ethup.se>
#
# dumppager.pl, a mutt pager that dumps the rendered mail to file
# 1. Edit the config variables in the script to suite your needs.
# 2. Set the mutt variable "pager" to the path of this script. 
# 3. Open mutt, and then read the mails you want to dump, one by 
#    one, in the order you want them dumped. 
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

use strict;
use warnings;
use feature qw/say/;

# BEGIN CONFIG
my $path = '/var/www/maildump'; 

my $fmt = '{n}-{f}-{s}-{d}';
# {n}: an incremental id for each mail (if target directory is 
#                                       empty when starting)
# {f}: contents of from field
# {s}: contents of subject field
# {d}: contents of date field

# END CONFIG

sub mkfname {
	my ($n, $from, $subject, $date);

	$from = substr $from, 0, 30;
	$subject = substr $subject, 0, 50;
	$n = int @n;
	$n = "0$n" if($n<10);

	my $fname = $fmt;

	$fname =~ s/{n}/$n/g;
	$fname =~ s/{f}/$from/g;
	$fname =~ s/{s}/$subject/g;
	$fname =~ s/{d}/$date/g;

	$fname=~s/[^\w\.\@ -]+/_/g;
	$fname="$path/$fname";

	return $fname;
}

die("$path is not a directory (or doesn't exist)") unless -d $path;

my @n=glob("$path/*");
my @mail = <>;

my($from,$subject,$date);
foreach(@mail) {
	$from = $1 if /^From: (.*)/i;
	$subject = $1 if /^Subject: (.*)/i;
	$date = $1 if /^Date: (.*)/i;
}

my $n = int @n;
mkfname($n, $from, $subject, $date);

open my $fh, '>', $fname;
foreach(@mail) {
	print $_;
	print $fh $_;
}
close $fh;

exit 0;
