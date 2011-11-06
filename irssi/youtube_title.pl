#!/usr/bin/perl
# Copyright 2009 -- 2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use strict;
use Irssi;
use LWP::UserAgent;
use XML::Simple;
use HTML::Entities;
use URI;
use URI::QueryParam;
use Regexp::Common qw/URI/;

my $VERSION = '0.52';

# changelog:
# 0.53, 2011-11-06:
#   * Support new domain hack "youtu.be"
#   * Whitelist invalid characters instead of blacklisting
# 0.52, 2011-09-10:
#   * Refactoring: changed name of callback subs; rearranged stuff
# 0.51, 2011-09-05:
#   * Bugfix release: "<url>," will fail (note the , character)
# 0.5, 2011-06-02:
#   * Optionally print info of own Youtube links (defaults to off)
#     (see setting "yt_print_own").
# 0.4, 2011-05-23:
#   * Also print out duration of video
#   * Broke out output code to subroutines
#   * Respect $PROXY envs
#   * Generally replaced hacks with available modules
#     - Replaced IO::Socket::INET with LWP::UserAgent
#     - Replaced regexp for XML parsing with XML::Simple
#     - Replaced regexp for HTML entity decoding with HTML::Entities
#     - Replaced URI parsing with regexp with URI.pm and Regexp::Common
# 0.32, 2010-06-05:
#   * added license header
#   * updated contact info
#   * minor formatting
# 0.31, 2009-10-15:
#   * formatting...
# 0.3:
#   * set the message level to CLIENTCRAP and put the text 
#     "youtube:" in yellow colour. 
# 0.21:
#   * whoa, fucked up bug. 
#     http://www.youtube.com/watch?hl=en&v=tqZiY2RdoO4&gl=US 
#     was posted to a channel, and my script got fucked up. 
#     it printed the title of the video ~5 times a second, 
#     until i checked irssi and had to kill the whole client.
#     	Anyways, it could have to do with the weird order 
#     of the query string, which is not to say that it's not 
#     my fault - 1. i should handle it, and 2. i should not 
#     fuck up irssi. What I did wrong was to check for one 
#     regexp, and when found remove another regexp - i should 
#     have deleted the same regexp, which i do now. 
#
# 0.2:
#   * regexp didn't match all youtube videos. if you have a 
#     variable in the query string before the v, it will not 
#     find it. And i also found out that all vs isn't 11 
#     characters.

my %IRSSI = (
	authors     => 'Olof \'zibri\' Johansson',
	contact     => 'olof@ethup.se',
	name        => 'youtube-title',
	description => 'prints the title of a youtube video automatically',
	license     => 'GNU APL',
);

Irssi::settings_add_bool('youtube_title', 'yt_print_own', 0);

sub callback {
	my($server, $msg, $nick, $address, $target) = @_;
	$target=$nick if $target eq undef;

	# process each youtube link in message
	process($server, $target, $_) for (get_ids($msg)); 
}

sub own_callback {
	my($server, $msg, $target) = @_;

	if(Irssi::settings_get_bool('yt_print_own')) { 
		callback($server, $msg, undef, undef, $target);
	}
}

sub process {
	my ($server, $target, $id) = @_;
	my $yt = get_title($id);
		
	if(exists $yt->{error}) {
		print_error($server, $target, $yt->{error});
	} else {
		print_title($server, $target, $yt->{title}, $yt->{duration});
	}
}

sub get_ids {
	my $msg = shift;
	my $re_uri = qr#$RE{URI}{HTTP}{-scheme=>'https?'}#;
	my @ids;

	foreach($msg =~ /$re_uri/g) {
		my $uri = URI->new($_);
		my $id;

		if($uri->host =~ /^(?:www\.)?youtube\.com$/) {
			next unless $uri->path eq '/watch';
			next unless $id = $uri->query_param('v');
		} elsif($uri->host =~ /^(?:www\.)?youtu\.be$/) {
			next unless ($id) = $uri->path =~ m;/(.*);
		}

		$id =~ s/[^\w-].*//;
		push @ids, $id;
	}

	return @ids;
}

# extract title using youtube api
# http://code.google.com/apis/youtube/2.0/developers_guide_protocol.html
sub get_title {
	my($vid)=@_;

	my $url = "http://gdata.youtube.com/feeds/api/videos/$vid";
	
	my $ua = LWP::UserAgent->new();
	$ua->agent("$IRSSI{name}/$VERSION (irssi)");
	$ua->timeout(3);
	$ua->env_proxy;

	my $response = $ua->get($url);

	if($response->code == 200) {
		my $content = $response->decoded_content;

		my $xml = XMLin($content)->{'media:group'};
		my $title = $xml->{'media:title'}->{content};
		my $s = $xml->{'yt:duration'}->{seconds};

		my $m = $s / 60;
		my $d = sprintf "%d:%02d", $m, $s % 60;

		if($title) {
			return {
				title => $title,
				duration => $d,
			};
		}

		return {error => 'could not find title'};
	}
	
	return {error => $response->message};
}

sub print_error {
	my ($server, $target, $msg) = @_;
	$server->window_item_find($target)->print(
		"%rError fetching youtube title:%n $msg", MSGLEVEL_CLIENTCRAP
	);
}

sub print_title {
	my ($server, $target, $title, $d) = @_;

	$title = decode_entities($title);
	$d = decode_entities($d);

	$server->window_item_find($target)->print(
		"%yyoutube:%n $title ($d)", MSGLEVEL_CLIENTCRAP
	);
}

Irssi::signal_add("message public", \&callback);
Irssi::signal_add("message private", \&callback);

Irssi::signal_add("message own_public", \&own_callback);
Irssi::signal_add("message own_private", \&own_callback);

