#!/usr/bin/perl
# vim: noexpandtab ts=8 sw=8:
# Copyright 2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use vars qw($VERSION);
$VERSION = '0.010';
my $APP  = 'svtplay';

use strict;
use warnings all => 'FATAL';
use feature qw/say/;
use LWP::Simple qw/get/;
use Getopt::Long;
use Pod::Usage qw/pod2usage/;

use Data::Dumper;

{
  package Data::Dumper;
  no strict "vars";

  $Terse = $Indent = $Useqq = $Deparse = $Sortkeys = 1;
  $Quotekeys = 0;
}


sub usage {
	pod2usage(
		verbose  => 99,
		exitval	 => 0,
		sections => q{DESCRIPTION|OPTIONS},
	);
}

usage() unless(@ARGV);

my $opts;
($opts->{bitrate}, $opts->{subtitle}) = (0, undef);
GetOptions(
	'b|bitrate:i'   => \$opts->{bitrate},  # XXX Not sure why we want this
					       # or how we should use it
	's|subtitle:s'  => \$opts->{subtitle}, # XXX What's this?

	'd|download'	=> \$opts->{download},
	'mp|mplayer'	=> \$opts->{mplayer},


	'h|help'	=> \&usage,
	'm|man'		=> sub { pod2usage(verbose => 3, exitval => 0) },
	'v|version'	=> sub { say("$APP v", __PACKAGE__->VERSION) && exit },
);

my $data = _get( shift );

if($opts->{download}) {
	download( $data->{url} );
	exit;
}
elsif($opts->{mplayer}) {
	mplayer( $data->{url } );
	exit;
}
else {
	say $data->{bitrate};
	say $data->{url};
	exit;
}

usage();


my @map_elems;
sub _get {
	my $uri  = shift;
	my $html =  get($uri) or die("Could not GET $uri: $!\n");
	my($flash_vars) = $html =~ m{<param name="flashvars" value="([^"]*)"};
	my ($urlmap) = $flash_vars =~ /dynamicStreams=(.*?)&amp;/;
	@map_elems = split /\|/, $urlmap;

	my %h = ();
	for my $e( map{ split(/,/, $_) } @map_elems ) {
		my($k, $v) = $e =~ m{ (\w+):(.+) }x;
		$h{$k} = $v;
	}
	return \%h;
}

sub download {
	my $url = shift;
	my $filename = time() . '.mp4';
	if($url =~ m{.+/(.+)mp4-[a-f]-v[1-9]}) {
		# skavlan5var20.mp4
		$filename = lc($1);
		$filename =~ s!^[A-Z]+-[0-9]{2,}-[0-9]{2,}(?:[A-Z]+)?-!!i;
	}
	else {
		$filename = $url =~ m{/(.+)$};
	}
	$filename =~ s{-+$}{};
	$filename .= '.mp4'; # no consistency from svt, fuck it
	print "using filename $filename\n\n";
	#system('rtmpdump', '-r', $url, '-o', $filename) == 0
	#	or die("rtmpdump: $!\n");
}

sub mplayer {
	my $url = shift;
	system('rtmpdump', '-r', $url, '|', 'mplayer', '-cache', 400) == 0
		or die($!);
}

__END__

=pod

=head1 NAME

svtplay - extract RTMP URLs from svtplay.se

=head1 DESCRIPTION

svtplay is a script that lets you extract RTMP URLs from  SVT Play.You can feed
this URL to e.g. rtmpdump and extract the video. Note, C<--subtitle> isn't
implemented yet.

=head1 SYNOPSIS

	svtplay [OPTION]... [URL]...

=head1 OPTIONS

  -b,	--bitrate
  -s,	--subtitle
  -d,	--download
  -mp,	--mplayer

  -h,	--help
  -v,	--version
  -m,	--man

=head1 SEE ALSO

L<https://github.com/trapd00r/utils/blob/master/svtplay>

=head1 AUTHOR

Olof 'zibri' Johansson

=head1 CONTRIBUTORS

    \ \ | / /
     \ \ - /
      \ | /
      (O O)
      ( < )
      (-=-)

  Magnus Woldrich
  CPAN ID: WOLDRICH
  magnus@trapd00r.se
  http://japh.se

=head1 COPYRIGHT

Copyright 2011 the B<svtplay.pl> L</AUTHOR> and L</CONTRIBUTORS> as listed
above.

=head1 LICENSE

This application is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
