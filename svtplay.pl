#!/usr/bin/perl
# Copyright 2011, 2012, Olof Johansson <olof@ethup.se>
# Copyright 2011, Magnus Woldrich <magnus@trapd00r.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use vars qw($VERSION);
$VERSION = '0.2'; # don't trust this... use git sha1
my $APP  = 'svtplay';

use strict;
use feature qw/say/;
use XML::Simple qw/XMLin/;
use LWP::Simple qw/get/;
use Getopt::Long qw/:config gnu_getopt/;
use Pod::Usage qw/pod2usage/;
use HTML::Entities;
use JSON;
use Data::Dumper;
use Encode;

package Video;

sub new {
	my $class = shift;
	my $jsonobj = shift;

	my %bitratemap = map {
		$_->{bitrate} => $_->{url}
	} @{$jsonobj->{video}->{videoReferences}};

	bless {
		%bitratemap,
		bitrates => [ keys %bitratemap ],
		id => $jsonobj->{videoId},
		filename => $jsonobj->{statistics}->{title},
		title => $jsonobj->{context}->{title},
		length => $jsonobj->{video}->{materialLength},
	}, $class;
}

sub bitrates {
	my $self = shift;
	return @{$self->{bitrates}};
}

sub url {
	my $self = shift;
	my $bitrate = shift;
	return $self->{$bitrate};
}

sub filename {
	my $self = shift;
	my $bitrate = shift;
	return $self->{filename} unless $bitrate;
	return "$self->{filename}.mp4" # is this what you call heuristics?
}

sub title {
	my $self = shift;
	return $self->{title};
}

package main;

sub usage {
	pod2usage(
		verbose  => 99,
		exitval  => 0,
		sections => q{DESCRIPTION|OPTIONS},
	);
}

usage() unless(@ARGV);

my $opts = {
	bitrate => 0,
	help => \&usage,
	version => sub { say("$APP v", __PACKAGE__->VERSION) && exit },
};
GetOptions($opts,
	'bitrate|b:i',
	'download|d',
	'output|o=s',
#	'force|f', # is this needed?
	'help|h',
	'version|v',
);

my $vid = _get( shift );

if($opts->{bitrate}) {
	if($opts->{download}) {
		download($vid, $opts->{bitrate});
	} else {
		say $vid->url($opts->{bitrate});
	}
} else {
	if($opts->{download}) {
		say "W: You have to do specify a bitrate";
	}

	for ($vid->bitrates) {
		say "$_: ", $vid->url($_);
	}
}

exit 0;

# the whole subroutine is ugly
sub _get {
	my $uri = shift;

	$uri .= '?type=embed' unless $uri =~ /\?/;
	$uri .= '&type=embed' unless $uri =~ /[?&]type=/;

	my $html = get($uri) or die("Could not GET $uri: $!\n");

	my($html_flash_vars) = $html =~
		/<param name="flashvars" value="json=([^"]*)"/;
	my $json_flash_vars = decode_entities($html_flash_vars);
	my $json_flash_vars_utf8 = encode(
		'utf-8', decode('iso-8859-1', $json_flash_vars)
	);
	my $flash_vars = decode_json($json_flash_vars_utf8);
	return Video->new($flash_vars);
}

sub download {
	my $vid = shift;
	my $bitrate = shift;

	my $url = $vid->url($bitrate);
	my $filename = $vid->filename($bitrate);
	print "using filename $filename\n\n";
	exec("rtmpdump -r $url -o $filename");
}

__END__

=pod

=head1 NAME

svtplay - extract RTMP URLs from svtplay.se

=head1 DESCRIPTION

svtplay is a script that lets you extract RTMP URLs from SVT Play.
You can feed this URL to e.g. rtmpdump and extract the video using
options to the script.

=head1 SYNOPSIS

  svtplay [OPTIONS] <URL>

=head1 OPTIONS

  -d, --download     download video
  -b, --bitrate      choose bitrate. only list available bitrates if omitted
  -o, --output file  specify output filename

  -h, --help         show the help and exit
  -v, --version      show version info and exit

=head1 CONTRIBUTORS

=over

=item Magnus Woldrich, magnus@trapd00r.se, http://japh.se, trapd00r on github

=back

=head1 COPYRIGHT

Copyright 2011, Olof Johansson <olof@ethup.se>
(and contributors...)

Copying and distribution of this file, with or without
modification, are permitted in any medium without royalty
provided the copyright notice are preserved. This file is
offered as-is, without any warranty.
