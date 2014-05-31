#!/usr/bin/perl
use 5.012;
use LWP::Simple;
use Getopt::Long qw(:config gnu_getopt);
use Pod::Usage;

GetOptions(my $opts = {
	output => 'livestream.flv',
	timeout => 60,
	help => sub { usage() },
}, qw(
	all|a
	verbose|v
	output|o=s
	force|f
	timeout|t=i
	help|h
));

sub usage {
	pod2usage({
		-verbose => 99,
		-sections => [qw(NAME SYNOPSIS OPTIONS)],
		-exitval => 0,
	});
}

my $url = shift;

my %seen;
my $n = 0;        # counting chunks
my $stale = time; # time of last new chunk downloaded

die "File $opts->{output} already exists\n"
	if -e $opts->{output} and not $opts->{force};

open my $fh, '>', $opts->{output} or
	die "Could not open $opts->{output}: $!\n";

sub get_parts {
	my $url = shift;
	# ignore the comments
	my @urls = grep { !/^#/ } split /\n/, get($url);
	return @urls;
}

if (! $opts->{all}) {
	$seen{$_} = 1 for get_parts($url);
}

while ($stale + $opts->{timeout} > time) {
	for my $chunk (get_parts($url)) {
		next if exists $seen{$chunk};
		printf "Downloading chunk %d\n", ++$n if $opts->{verbose};
		print $fh get($chunk);
		$stale = time;
		$seen{$chunk} = 1;
	}

	sleep 5; # don't kill 'em
}

close $fh;

print STDERR "I *think* that was all...\n";
exit(0);

__DATA__
=head1 NAME

live-hls.pl - download a live HLS stream

=head1 SYNOPSIS

 live-hls --output liveshow.flv
 live-hls --help

=head1 DESCRIPTION

Download a live HLS stream.

=head1 OPTIONS

=over

=item --output <filename>

Save stream to file. Default is to save to out.flv.

=item --force

By default, the script will die if the file exists. By using this
flag, you can force the script to truncate the old file.

=item --timeout <ttl>

When not seen any new chunks for <ttl> seconds, exit the script. The
stream is probably done. Default is 60 seconds.

=item --all

Download all chunks. Default is to only download the chunks not seen
when starting the script.

=item --verbose

Verbose output.

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without
modification, are permitted in any medium without royalty
provided the copyright notice are preserved. This file is
offered as-is, without any warranty.
