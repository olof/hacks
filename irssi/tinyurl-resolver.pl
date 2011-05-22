#!/usr/bin/perl
# Copyright 2009-2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

use strict;
use LWP::UserAgent;
use Irssi;

my $VERSION = '0.4';
my %IRSSI = (
    authors     => 'Olof \'zibri\' Johansson',
    contact     => 'olof@ethup.se',
    name        => 'tinyurl-resolver',
    description => 'resolve tinyurl, et al',
    license     => 'GNU APL',
);

# 2011-02-13, 0.4:
# * added support for multiple url shortening services
# * changed license to GNU APL

# This started of as a modified version of youtube-title.pl 
# See also:
# * http://www.stdlib.se/
# * https://github.com/olof/hacks/tree/master/irssi

my $debug = 1;
my $prefix = qr,(?:http://(?:www\.)?|www\.),;
my @tinyfiers = (
	qr,${prefix}tinyurl\.com/\w+,,
	qr,${prefix}bit\.ly/\w+,,
	qr,${prefix}cot\.ag/\w+,,
	qr,${prefix}ow\.ly/\w+,,
	qr,${prefix}goo\.gl/\w+,,
	qr,${prefix}tiny\.cc/\w+,,
	qr,${prefix}t\.co/\w+,,
	qr,${prefix}gaa\.st/\w+,,
	qr,${prefix}wth\.se/\w+,,
);

sub hastiny {
	my($msg) = @_;

	foreach(@tinyfiers) {
		if(my($url) = $msg =~ /($_)/i) {
			if($url =~ /^www/i) {
				return "http://$url";
			}

			return $url;
		}
	}

	return undef;
}

sub resolve {
	my($server, $msg, $nick, $address, $target) = @_;
	$target=$nick if $target eq undef;

	while(my $url = hastiny($msg)) {
		my $loc = get_location($url);
		
		if($loc) {
			$server->window_item_find($target)->print(
				"%y$url%n -> $loc", 
				MSGLEVEL_CLIENTCRAP
			);
		} elsif($debug) {
			$server->window_item_find($target)->print(
				"%y$url:%n invalid link", 
				MSGLEVEL_CLIENTCRAP
			);
		}

		$msg =~ s/$url//;
	}
}

sub get_location {
	my $location;
	my ($url) = @_;
	
	my ($host) = $url =~ m,http://(.[^/:]+)/,;
	return undef unless defined $host;

	my $ua = LWP::UserAgent->new(
		max_redirect => 0,
	);

	$ua->agent("$IRSSI{name}/$VERSION (irssi)");
	$ua->timeout(3);
	$ua->env_proxy;

	my $response = $ua->head($url);

	return $response->header('location'); 
}

Irssi::signal_add("message public", \&resolve);
Irssi::signal_add("message private", \&resolve);

