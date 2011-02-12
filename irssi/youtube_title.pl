#!/usr/bin/perl
# Copyright 2009, 2010, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use strict;
use IO::Socket::INET;
use Irssi;

my $VERSION = '0.32';

# changelog:
# 0.32, 2010-06-05:
#	* added license header
#	* updated contact info
#	* minor formatting
# 0.31, 2009-10-15:
#	* formatting...
# 0.3:
# 	* set the message level to CLIENTCRAP and put the text 
#         "youtube:" in yellow colour. 
# 0.21:
#	* whoa, fucked up bug. 
#         http://www.youtube.com/watch?hl=en&v=tqZiY2RdoO4&gl=US 
#         was posted to a channel, and my script got fucked up. 
#         it printed the title of the video ~5 times a second, 
#         until i checked irssi and had to kill the whole client.
#	  	Anyways, it could have to do with the weird order 
#         of the query string, which is not to say that it's not 
#         my fault - 1. i should handle it, and 2. i should not 
#         fuck up irssi. What I did wrong was to check for one 
#         regexp, and when found remove another regexp - i should 
#         have deleted the same regexp, which i do now. 
#
# 0.2:
#	* regexp didn't match all youtube videos. if you have a 
#         variable in the query string before the v, it will not 
#         find it. And i also found out that all vs isn't 11 
#         characters.

my %IRSSI = (
    authors     => 'Olof \'zibri\' Johansson',
    contact     => 'olof@ethup.se',
    name        => 'youtube-title',
    description => 'prints the title of a youtube video automatically',
    license     => 'GNU APL',
);

my $debug = 0;

#does the message contain youtube.com/watch?v=<video id>?
sub isutube {
	my($server, $msg, $nick, $address, $target) = @_;
	$target=$nick if $target eq undef;
	
	# for each link to youtube.com/watch?v=... print the title
	# example: http://www.youtube.com/watch?v=59FCAYKyR00
	while($msg=~ m"
		(?:http://|www\.|http://www\.)youtube\.com/
		watch\?\S*v=([^\s&\?\.,!]+)
	"x) {
		my $title = get_title($1) if($1 ne undef);
		
		if($title ne undef) {
			# Decode html entities. If more are needed - i.e 
			# are shown as &foo; when printed in irssi - send 
			# me a mail at olof@ethup.se
			$title =~ s/&amp;/&/;
			$title =~ s/&lt;/</;
			$title =~ s/&gt;/>/;

			$server->window_item_find($target)->
				print("%yyoutube:%n $title", 
				MSGLEVEL_CLIENTCRAP);
		}

		$msg =~ s"(?:http://|www\.|http://www\.)youtube\.com/
		          watch\?\S*v=[^\s&\?\.,!]+""x;
	}
}

# extract title using youtube api
# http://code.google.com/apis/youtube/2.0/developers_guide_protocol.html
sub get_title {
	my($vid)=@_;
	
	my $sock = IO::Socket::INET->new( 
		PeerAddr=>'gdata.youtube.com',
		PeerPort=>'http(80)',
		Proto=>'tcp',
	);
	
	my $req="GET /feeds/api/videos/$vid HTTP/1.0\r\n";
	$req.="host: gdata.youtube.com\r\n";
	$req.="user-agent: $IRSSI{'name'}-$VERSION (irssi script)\r\n";
	$req.="\r\n";
	
	print $sock $req;
	while(<$sock>) {
		if(/<media:title type='plain'>(.*)<\/media:title>/) {
			close $sock;
			return $1;
		}
	}
	
	return undef;
}

Irssi::signal_add("message public", \&isutube);
Irssi::signal_add("message private", \&isutube);

