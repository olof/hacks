#!/usr/bin/perl
# Copyright 2011, Olof Johansson <olof@ethup.se>
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
use Getopt::Long;
use Pod::Usage qw/pod2usage/;

sub usage {
	pod2usage(
		verbose  => 99,
		exitval  => 0,
		sections => q{DESCRIPTION|OPTIONS},
	);
}

usage() unless(@ARGV);

my $opts;
($opts->{bitrate}, $opts->{subtitle}, $opts->{list}) = (0, undef, undef);
GetOptions(
	'b|bitrate:i'   => \$opts->{bitrate},
	'd|download'    => \$opts->{download},
	'h|help'        => \&usage,
	'v|version'     => sub { say("$APP v", __PACKAGE__->VERSION) && exit },
);


my $data = _get( shift );

if($opts->{bitrate}) {
	if($opts->{download}) {
		download( $data->{$opts->{bitrate}} );
	} else {
		say $data->{$opts->{bitrate}};
	}
} else {
	if($opts->{download}) {
		say "W: You have to do specify a bitrate";
	}

	foreach(keys %{$data}) {
		say "$_: $data->{$_}";
	}
}

exit 0;

sub _get {
	my $uri = shift;

	my $html = get($uri) or die("Could not GET $uri: $!\n");

	my($flash_vars) = $html =~ /<param name="flashvars" value="([^"]*)"/;
	my ($urlmap) = $flash_vars =~ /dynamicStreams=(.*?)&amp;/;
	
	my %h;
	for my $elm (split /\|/, $urlmap) {
		my %fmt;

		for my $e (split(/,/, $elm, 2)) {
			my($k, $v) = $e =~ / (\w+):(.+) /x;
			$fmt{$k} = $v;
		}

		$h{$fmt{bitrate}} = $fmt{url};
	}

	return \%h;
}

sub download {
	my $url = shift;
	my $filename = time() . '.mp4';
	if($url =~ m{.+/(.+)mp4-[a-f]-v[1-9]}) {
		$filename = lc($1);
		$filename =~ s!^[A-Z]+-[0-9]{2,}-[0-9]{2,}(?:[A-Z]+)?-!!i;
	} else {
		$filename = $url =~ m{/(.+)$};
	}
	$filename =~ s{-+$}{};
	$filename .= '.mp4'; # no consistency from svt, fuck it
	print "using filename $filename\n\n";
	system('rtmpdump', '-r', $url, '-o', $filename) == 0
		or die("rtmpdump: $!\n");
}

__END__

=pod

=head1 NAME

svtplay - extract RTMP URLs from svtplay.se

=head1 DESCRIPTION

svtplay is a script that lets you extract RTMP URLs from SVT Play.
You can feed this URL to e.g. rtmpdump and extract the video. 

=head1 SYNOPSIS

  svtplay [OPTIONS] <URL>

=head1 OPTIONS

  -d, --download   download video to ./
  -b, --bitrate    choose bitrate. only list available bitrates if omitted

  -h, --help       show the help and exit
  -v, --version    show version info and exit

=head1 SEE ALSO

L<https://github.com/trapd00r/utils/blob/master/svtplay>

=head1 AUTHOR

Olof 'zibri' Johansson, <olof@ethup.se>

=head1 CONTRIBUTORS

=over

=item Magnus Woldrich, magnus@trapd00r.se, http://japh.se, trapd00r on github

=back

=head1 COPYRIGHT

Copyright 2011 the B<svtplay.pl> L</AUTHOR> and L</CONTRIBUTORS> as listed
above.

=head1 LICENSE

This application is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

