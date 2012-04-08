#!/usr/bin/perl
use warnings;
use strict;
use feature qw/say/;
use File::Basename qw/basename/;

# CONFIGURATION
my $opts = {
	# Where do you sync your RFC archive to?
	'src_base' => '/mirror/ietf-rfcs', # (yeah, no FHS... naughty us :-))

	# Where, relative to the index URL should links point to?
	# Example:
	#
	#   http://rfc.ethup.se/        Index
        #   http://rfc.ethup.se/rfc     The actual contents
	#
	# In our setup, the dest_base is an Apache alias to src_base.
	'dest_base' => 'rfc',
};
# END CONFIGURATION

my $index =<< 'EOF';
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" href="style.css" type="text/css" />
  <title>[%title%]</title>
 </head>
 <body>
  [%content%]
  <hr />
  <p>Hosted by <a href="http://ethup.se/">ethup.se</a>.</p>
 </body>
</html>
EOF

my $content =<< 'EOF';
  <ul class="entries">
[%entries%]
  </ul>
EOF

my $entries_content =<< "EOF";
  <p><a href="/">[ Back ]</a></p>
  $content
  <p><a href="/">[ Back ]</a></p>
EOF

my $entry =<< 'EOF';
   <li class="entry">[%url%]</li>
EOF

my $rfc_url = '<a href="[%base%]/rfc[%rfcn%].txt">RFC [%rfcn%]</a>';
my $index_url = '<a href="index_[%base%].html">RFC [%base%]</a>';

sub fname2rfcn {
	my $fname = shift;
	return basename($fname) =~ /^rfc([0-9]+)\.txt$/;
}

sub gen_slice_index_base {
	return int($_[0]/100) . 'xx';
}

sub gen_slice_index {
	my $fnbase = gen_slice_index_base($_[0]);
	open my $fh, '>', "index_$fnbase.html";

	print $fh template( $index,
		title => "ethup.se RFC archive: $_[0] -- $_[$#_]",
		content => template($entries_content,
			entries => join('',
				map { template($entry, url => $_) }
				map { template($rfc_url,
					base => $opts->{dest_base},
					rfcn => $_
				) }
				sort { $a <=> $b }
				@_
			)
		)
	);

	close $fh;

	return $fnbase;
}

sub gen_index {
	open my $fh, '>', 'index.html';
	
	print $fh template( $index,
		title => "ethup.se RFC archive",
		content => template($content,
			entries => join('',
				map { template($entry, url => $_) }
				map { template($index_url, base => $_) } 
				@_
			)
		)
	);
}

sub template {
	my $tmpl = shift;
	my $stash = { @_ };

	$tmpl =~ s/\[%\s*$_\s*%\]/$stash->{$_}/mg for keys %$stash;

	return $tmpl;
}

my @rfcs =
	sort { $a <=> $b }
	map { fname2rfcn($_) }
	grep /\/rfc[0-9]+\.txt$/,
	glob("$opts->{src_base}/rfc*.txt");

my @indexes;
my $lim = 0;
for my $i ( 0 .. int ( $rfcs[$#rfcs] / 100 ) ) {
	my @rfc_slice;
	$lim += 100;

	push @rfc_slice, shift @rfcs while @rfcs and $rfcs[0] < $lim;
	push @indexes, gen_slice_index(@rfc_slice);
}

gen_index(@indexes);

__END__

=head1 NAME

rfc-sliced-index, generate index slices for the RFC archives

=head1 USAGE

This script is probably only usable for people mirroring the RFC
archive (easily adaptable to other similarly named document series).

It's intended to run as a tail to a cronjob rsyncing the RFC archive.
When the rsync is complete, the script will generate static HTML with
sliced indexes for the archive. To use it, the hash $opts at the top
of the file should be modified to fit your environment. See inline
comments for description of the settings.

The script should be run with PWD set to the top directory of the
web document root.

=head1 DESCRIPTION

The list of published RFC is long (as of writing this, there are just
under 6600 RFCs). Generating a index file with all RFCs in a long list
creates a pretty large file, large enough to make (at least) Firefox a
bit sluggish. Just a plaintext listing of all the files is almost 
80 KiB. Having the Apache generated directory listings as a default
index page for visitors to a RFC archive mirror is therefore _not_
recommended.

One simple solution is to slice the index up to sub-indexes of 100
RFCs each. This can easily be generated as static HTML on sync time,
which I see as a hugh plus.

And yes, this script is a ugly pretty hack, thank you, glad you
noticed!

=head1 KNOWN BUGS AND LIMITATIONS

The script should use Getopt::Long to change settings, instead of
hardcoding them.

The script should chdir to the web document root (don't want to
implement this before I've implemented the Getopt bug/missing
feature).

This script can currently only be used for mirrors with a own domain,
e.g. rfc.ethup.se. Shouldn't be too hard to fix correctly, but I don't
currently have the need. Quick fix is to change the [ Back ] link in
the entries_content template to point to the relative URL instead of
/.

=head1 SEE ALSO

=over

=item * L<http://rfc-editor.org/>

=item * L<http://www.rfc-editor.org/rsync-help.html>

=item * L<https://www.rfc-editor.org/mailman/listinfo>

=back

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>
