#!/usr/bin/perl
# vim: noexpandtab ts=8 sw=8:
# Copyright 2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use vars qw($VERSION);
$VERSION = '0.012';
my $APP  = 'svtplay';

use strict;
use warnings all => 'FATAL';
use feature qw/say/;
use XML::Simple qw/XMLin/;
use LWP::Simple qw/get/;
use Getopt::Long;
use Pod::Usage qw/pod2usage/;

#use Data::Dumper;
#
#{
#  package Data::Dumper;
#  no strict "vars";
#
#  $Terse = $Indent = $Useqq = $Deparse = $Sortkeys = 1;
#  $Quotekeys = 0;
#}


sub usage {
	pod2usage(
		verbose  => 99,
		exitval	 => 0,
		sections => q{DESCRIPTION|OPTIONS},
	);
}

usage() unless(@ARGV);

my $opts;
($opts->{bitrate}, $opts->{subtitle}, $opts->{list}) = (0, undef, undef);
GetOptions(
	'b|bitrate:i'   => \$opts->{bitrate},  # XXX Not sure why we want this
					       # or how we should use it
	's|subtitle:s'  => \$opts->{subtitle}, # XXX What's this?

	'd|download'	=> \$opts->{download},
	'mp|mplayer'	=> \$opts->{mplayer},
	'l|list|recent' => \$opts->{list},


	'h|help'	=> \&usage,
	'm|man'		=> sub { pod2usage(verbose => 3, exitval => 0) },
	'v|version'	=> sub { say("$APP v", __PACKAGE__->VERSION) && exit },
);


# XXX
my %svt_feeds = (
	rapport	=> '96238?vformat=flv&tag=playrapport',
	kultur	=> '103478?expression=full&mode=plain',
	recent	=> '96238?expression=full&mode=plain',
);

my $data;
if($opts->{list}) {
	my $recent = recent();
	$data = _get( $recent->{url} );
}
else {
	$data = _get( shift );
}


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

sub recent {
	my $base = 'http://feeds.svtplay.se/v1/video/list/';
	my $feed = shift;
	$feed //= $base . $svt_feeds{recent};

	my $programs = XMLin( get($feed) );

	my($i, %shows) = (1, ());
	for my $p(@{$programs->{channel}->{item}}) {
		$shows{$i} = $p->{link};
		printf("% 3d => %s\n", $i, $p->{title});
		$i++;
	}
	my $choice;
	ANSWER:
	{
		print "\n> ";
		chomp( $choice = <STDIN> );
		if($choice !~ /^[0-9]+$/) {
			print Dumper $choice;
			warn("Not a number: '$choice'\n");
			goto ANSWER;
		}
		if( (( $choice +1 ) > $i) || ($choice < 1) ) {
			print "I IS $i\n\n";
			warn("Number 1 .. $i expected\n");
			goto ANSWER;
		}
						 # for now
		return { url => $shows{$choice}, bitrate => 0, }
	}
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
	system('rtmpdump', '-r', $url, '-o', $filename) == 0
		or die("rtmpdump: $!\n");
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

  -d,	--download	download video to ./
  -mp,	--mplayer	play video using mplayer
  -l,	--list		pick a video from the most recent ones
  -b,	--bitrate	choose bitrate?
  -s,	--subtitle	choose subtitle?

  -h,	--help		show the help and exit
  -v,	--version	show version info and exit
  -m,	--man		show the manual and exit

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
