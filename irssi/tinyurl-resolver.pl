#!/usr/bin/perl
use strict;
use IO::Socket::INET;
use Irssi;

my $VERSION = '0.3';
my %IRSSI = (
    authors     => 'Olof \'zibri\' Johansson',
    contact     => 'olof@ethup.se',
    name        => 'tinyurl-resolver',
    description => 'resolve tinyurl',
    license     => 'GPLv2 or later',
);

# modified version of youtube-title.pl 
# http://www.stdlib.se/

my $debug = 1;

sub istiny {
	my($server, $msg, $nick, $address, $target) = @_;
	$target=$nick if $target eq undef;

	while($msg=~ /(?:http:\/\/(?:www\.)?|(?:www\.)?)tinyurl\.com\/(\w+)/) {
		my $loc = get_location($1) if($1 ne undef);
		
		if($loc ne undef) {
			$server->window_item_find($target)->
				print("%ytinyurl.com%n/$1 -> $loc", MSGLEVEL_CLIENTCRAP);
		} else {
			$server->window_item_find($target)->
				print("%ytinyurl:%n invalid tinyurl link", MSGLEVEL_CLIENTCRAP);
		}

		$msg =~ s/(?:http:\/\/(?:www\.)?|(?:www\.)?)tinyurl\.com\/\w+//;
	}
}

sub get_location {
	my $location;
	my ($id) = @_;
	
	my $sock = IO::Socket::INET->new (
		PeerAddr => 'tinyurl.com',
		PeerPort => 'http(80)',
		Proto => 'tcp',
	);
	
	print $sock "GET /$id HTTP/1.1\r\n".
	            "host: tinyurl.com\r\n".
	            "user-agent: anti-tinyurl/0.1\r\n".
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

