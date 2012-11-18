#!/usr/bin/perl
# Copyright 2012, Olof Johansson <olof@ethup.se>
# 
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use 5.012;

use URI;
use LWP::UserAgent;
use XML::Feed;
use Text::Wrapper;
use File::Basename;
use HTML::FormatText;

# FIXME: better mail support (we now rely on cron to mail for us)
# FIXME: Document!
# FIXME: Add better configuration support (esp. wrt dest path)

my $podlist = "$ENV{HOME}/.podcasts";
my $poddest = "$ENV{HOME}/media/podcasts";

sub alert {
	my $pod = shift;
	my $entry = shift;
	my $wrapper = Text::Wrapper->new(columns => 65);

	printf "Downloaded episode of %s\n", $pod;
	printf "Episode: %s\n", $entry->title;
	print "\n";

	my $mime = $entry->content->type;
	my $body = $entry->content->body;
	my $summary;

	if ($mime eq 'text/plain') {
		$summary = $body;
	} elsif ($mime eq 'text/html') {
		$summary = HTML::FormatText->format_string(
			$body,
			leftmargin => 0, rightmargin => 65
		);
	}
	
	print $wrapper->wrap($summary) if defined $summary;

	say "===========";
}

sub download {
	my ($pod, $item) = @_;
	my $enc = $item->enclosure;

	if (not defined $enc) {
		warn "Item has no media enclosure. Not a podcast?\n";
		return;
	}

	my $uri = URI->new($enc->url);
	my $filename = basename($uri->path);
	my $poddir = "$poddest/$pod";
	my $filedest = "$poddir/$filename";

	if (! -e $poddir) {
		mkdir $poddir or die "Could not create $poddir\n";
	}

	if (! -d $poddir) {
		die "$poddir exists, but is not a directory\n";
	}

	return if -e $filedest;

	my $ua = LWP::UserAgent->new();
	
	$ua->env_proxy;
	$ua->timeout(20);

	my $resp = $ua->get($uri, ':content_file' => $filedest);

	if ($resp->is_success) {
		alert($pod, $item);
	} else {
		say "Error: Could not download $uri ($pod)";
		say $resp->status_line;
		say "======================";
		return 0;
	}

	return 1;
}

my %rss;
open my $fh, '<', $podlist or die "Could not open podlist: $!\n";
my $n = 0;

while(<$fh>) {
	my $m = 0;
	my ($pod, $uri) = /^(\w+):\s*(.*)/;
	my $feed = XML::Feed->parse(URI->new($uri)) or
		die XML::Feed->errstr;
	
	for my $item ($feed->entries) {
		download($pod, $item) and ++$m;
	}

	say STDERR "Downloaded $m new episodes of $pod";

	$n += $m;
}

if ($n) {
	say STDERR "Downloaded $n new episodes, in total";
} else {
	say STDERR "No new episodes."
}
