#!/usr/bin/perl
# Youtube streamer / downloader
# Deps: URI::Escape, LWP::Simple, mplayer
#
# Copyright (c) 2011 - Olof Johansson <olof@ethup.se>
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself.

our $VERSION = 3.141;
use warnings;
use strict;
use LWP::Simple qw/get/;
use URI::Escape;
use Data::Dumper;
use Getopt::Long;

my @pref = qw/45 44 43 18/;
my $opts = {};
GetOptions($opts, 'itag=i', 'dumper');

@ARGV > 0 || die('needs an uri as argument');
my $html = get($ARGV[0]);
my ($map) = $html =~ /url_encoded_fmt_stream_map=(.*?);/;
my %map = map { 
	my $tmp = {
		map { 
			my @kv=split /=/, $_; $kv[1]='null' if @kv==1; @kv 
		} split /&/, $_
	}; 
	$tmp->{url} = uri_unescape($tmp->{url});
	($tmp->{itag} => $tmp)
} split/,/,uri_unescape($map);

$opts->{dumper} && do { print Dumper(\%map); exit 0 };

my $uri;
$uri = $map{$opts->{itag}}->{url};
$uri = $map{$_}->{url} while(!$uri && ($_ = shift @pref));
die("couldn't find uri...") unless $uri;
system("mplayer -fs '$uri'");

