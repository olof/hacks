#!/usr/bin/perl
# Copyright 2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

use strict;
use warnings;
use feature qw/say/;
use LWP::Simple qw/get/;
use Data::Dumper;
use Getopt::Long;

sub usage {
	print << "EOF";
$0 [--subtitle] [--bitrate <bitrate>] <url>
$0 --help

svtplay.pl is a script that lets you extract RTMP URLs from 
SVT Play. You can feed this URL to e.g. rtmpdump and extract 
the video. Note, --subtitle isn't implemented yet.
EOF
	exit(0);
}

my ($bitrate, $subtitle);
GetOptions(
	'help' => \&usage,
	'bitrate=i' => \$bitrate,
	'subtitle', => \$subtitle,
);

usage() unless(@ARGV);

my $html = get("http://svtplay.se/t/102959/pa_sparet");
my ($flashvars) = $html =~ /<param name="flashvars" value="([^"]*)"/;
my ($urlmap) = $flashvars =~ /dynamicStreams=(.*?)&amp;/;
my @mapelms = split /\|/, $urlmap;

my %hash;
foreach(@mapelms) {
	my %h;
	my @elms = split /,/;
	foreach(@elms) {
		my($k,$v) = split /:/, $_, 2;
		$h{$k}=$v;
	}

	if(exists $h{bitrate}) {
		$hash{$h{bitrate}}=$h{url}
	}
}

if(defined $bitrate) {
	say $hash{$bitrate};
} else {
	foreach(sort {$a<=>$b} keys %hash) {
		say "$_: $hash{$_}";
	}
}

