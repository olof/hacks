#!/usr/bin/perl
# Copyright 2009-2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

use strict;
use IO::Socket::INET;
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
);

sub hastiny {
	my($msg) = @_;

	foreach(@tinyfiers) {
		if(my($url) = $msg =~ /($_)/) {
			if($url =~ /^www/) {
				return "http://$url";
			}

			return $url;
		}
	}

	return undef;
}

sub istiny {
	my($server, $msg, $nick, $address, $target) = @_;
	$target=$nick if $target eq undef;

	while(my $url = hastiny($msg)) {
		my $loc = get_location($url);
		
		if($loc) {
			$server->window_item_find($target)->print(
				"%y$url%n/$1 -> $loc", 
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

	my $sock = IO::Socket::INET->new (
		PeerAddr => $host,
		PeerPort => 'http(80)',
		Proto => 'tcp',
	);
	
	print $sock "GET $url HTTP/1.1\r\n".
	            "host: $host\r\n".
	            "user-agent: tinyurl-resolver/0.4 (irssi)\r\n".
	            "\r\n";
	
	while(<$sock>) {
		if(/^Location: (\S+)\r\n$/si) {
			$location=$1;
			last;
		}
	}

	close $sock;
	return $location; 
}

Irssi::signal_add("message public", \&istiny);
Irssi::signal_add("message private", \&istiny);

