#!/usr/bin/perl
# vim: noexpandtab ts=8 sw=8:
# Copyright 2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use vars qw($VERSION);
$VERSION = '0.002';
my $APP  = 'svtplay';

use strict;
use warnings all => 'FATAL';
use feature qw/say/;
use LWP::Simple qw/get/;
#use Data::Dumper;
use Getopt::Long;
use Pod::Usage qw/pod2usage/;

sub usage {
	pod2usage(
		verbose  => 99,
		exitval	 => 0,
		sections => q{DESCRIPTION|OPTIONS},
	);
}

#usage() unless(@ARGV);

my ($bitrate, $subtitle);
GetOptions(
	'b|bitrate:i'   => \$bitrate,
	's|subtitle:s'  => \$subtitle,

	'h|help'	=> \&usage,
	'm|man'		=> sub { pod2usage(verbose => 3, exitval => 0) },
	'v|version'	=> sub { say("$APP v", __PACKAGE__->VERSION) && exit },
);


my $uri = shift;

my $html = get($uri) or die($!);
my ($flashvars) = $html =~ /<param name="flashvars" value="([^"]*)"/;
my ($urlmap) = $flashvars =~ /dynamicStreams=(.*?)&amp;/;
my @mapelms = split /\|/, $urlmap;

my %hash;
foreach(@mapelms) {
	print ">>> $_\n";
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

=pod

=head1 NAME

svtplay - extract RTMP URLs from svtplay.se

=head1 DESCRIPTION

svtplay is a script that lets you extract RTMP URLs from  SVT Play.You can feed
this URL to e.g. rtmpdump and extract the video. Note, C<--subtitle> isn't
implemented yet.

=head1 OPTIONS

  -b,	--bitrate
  -s,	--subtitle

  -h,	--help
  -v,	--version
  -m,	--man

=cut
