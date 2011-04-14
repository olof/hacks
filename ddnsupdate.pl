#!/usr/bin/perl
# ddnsupdate - nsupdate based ddns script, draft
#
# Copyright (c) 2011 - Olof Johansson <olof@ethup.se>
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself.

# Dependencies:
# * LWP
# * Regexp::Common
# * Regexp::IPv6
# * Net::Bind::Update (not published on CPAN yet)

use warnings;
use strict;
use LWP::Simple qw/get/;
use Net::Bind9::Update;
use Regexp::Common qw/net/;
use Regexp::IPv6 qw/$IPv6_re/;
use Config::Simple;

my $config = new Config::Simple('/etc/ddnsupdate/config') or die(
	"Could not read config file (/etc/dnssupdate/config): " 
	. Config::Simple->error()
);

my $hostname = $config->param('hostname'); 
my $zone = $config->param('zone');
my $keyfile = $config->param('keyfile');
my $ttl = $config->param('ttl') // 600;
my $datadir = '/var/lib/ddnsupdate';

die("Not defined: host") unless $hostname;
die("Not defined: zone") unless $zone;
die("Not defined: keyfile") unless $keyfile;

# the extsrces should be hosts that you trust, optimally using https
my $remote4 = $config->param('remote4')//'http://ipv4.ethup.se/cgi-bin/ip.cgi';
my $remote6 = $config->param('remote6')//'http://ipv6.ethup.se/cgi-bin/ip.cgi';

my $fh;
my ($ipv4, $ipv6);
my $currentf = "$datadir/current";

if(-f $currentf) {
	open $fh, '<', $currentf or die("failed opening $currentf: $!");
	while(<$fh>) {
		my ($key, $val) = split /,/;
		$ipv4 = $val if $key eq 'ipv4';
		$ipv6 = $val if $key eq 'ipv6';
	}
	close $fh;
}

$zone .= '.' unless $zone =~ /\.$/;
my $nsupdate = Net::Bind9::Update->new(
	origin => $zone,
	ttl => $ttl,
	keyfile => $keyfile,
	datadir => $datadir,
);

my $exec = 0;
$nsupdate->del(name=>$hostname);

if($remote4) {
	my $addr = get($remote4);

	if(defined $addr and $addr =~ /^$RE{net}{IPv4}$/ and 
	   (not defined $ipv4 or $addr ne $ipv4)) {
	   	print "update with A $addr\n";
		$ipv4 = $addr;
		$nsupdate->add(
			name=>$hostname,
			type=>'A',
			data=>$addr,
		);
		$exec = 1;
	} else {
		$ipv4 = undef;
	}
} elsif(defined $ipv4) {
	$ipv4 = undef;
	$exec = 1;
}

if($remote6) {
	my $addr = get($remote6);

	if(defined $addr and $addr =~ /^$IPv6_re$/ and
	   (not defined $ipv6 or $addr ne $ipv6)) {
		print "update with AAAA $addr\n";
		$ipv6 = $addr;
		$nsupdate->add(
			name=>$hostname,
			type=>'AAAA',
			data=>$addr,
		);
		$exec = 1;
	} else {
		$ipv6 = undef;
	}
} elsif(defined $ipv6) {
	$ipv6 = undef;
	$exec = 1;
}

if($exec) {
	$nsupdate->execute() or die("oops");

	open $fh, '>', $currentf or die("failed opening $currentf: $!");
	print $fh "ipv4,$ipv4" if defined $ipv4;
	print $fh "ipv6,$ipv6" if defined $ipv6;
	close $fh;
}

=head1 NAME

ddnsupdate - an nsupdate based dyndns script

=head1 SYNOPSIS

B<ddnsupdate>

=head1 DESCRIPTION

ddnsupdate is used by mobile hosts or hosts on network without static
addresses to always have a up-to-date domain name to use for accessing
it. Some services exist to make it easy for you, but why do it the 
easy way? With this script, you'll be in total control over your zones
at all times, without relying on any services running on the server 
(except for Bind9 itself, of course). 

To make this happen you'll only have to create a zone to use for your
dynamic hosts, make it dynamic, and then add keys for these zones in
the named configuration. These keys should be different for all your
hosts to be able to revoke access for a single compromised key. Also 
notice that you should not let anybody else use this zone, as anybody 
with a key could erase all your domains.

=head2 DEPENDENCIES

The script depends on the following Perl modules, available through
CPAN:

=over

=item * Net::Bind9::Update (unpublished)

=item * LWP::Simple (LWP)

=item * Regexp::Common

=item * Regexp::IPv6 

=item * Config::Simple

=back

=head1 CONFIGURATION

Example:

 hostname asimov
 zone ddns.x20.se.
 keyfile Kkey-asimov.+157+12490
 remote4 http://ipv4.ethup.se/cgi-bin/ip.cgi
 remote6 http://ipv6.ethup.se/cgi-bin/ip.cgi
 ttl 600

The configuration file format is defined by Config::Simple. 

=head2 hostname

Contains the hostname for your host. Beware that if you use the
same value on multiple host, it will be updated to point to the
host that updates it last. It will be messy. Required.

=head2 zone

The zone in which your hostname resides, i.e. the part after 
the hostname. If you're intended domain name would be 
host1.example.com, "example.com." is your zone. Required.

=head2 keyfile

For this to work, you will need to have a shared secret 
configured on the server. Your copy of this secret will reside
in a file. With the keyfile attribute, you specify where you
have it stored. Obviously, the invoker of the script needs to 
have read access to it. Required.

=head2 remote4 and remote6

remote4 and remote6 are remote servers used to identify your IP 
addresses (v4 or v6) in case of IP masquerading. If this is left
out, the machine's IP address will be used instead. If you have
multiple addresses one will be taken "randomly".

Make sure that the remote servers can be trusted: if they are
malicious, they can put arbitrary addresses to your hostnames.

=head2 ttl

The TTL value of your domain is defined by the ttl attribute in
the config file. You can leave it undefined for a default value
to kick in. The default value is at 600 seconds (which is somewhat
low, but the dynamic nature of IP addresses for end users makes 
it hard to go much higher).

=head1 FILES

=over

=item * /etc/ddnsupdate/config

The configuration file. See the CONFIGURATION section in this 
document.

=item * /var/lib/ddnsupdate/

Directory for temporary nsupdate files.

=back

=head1 COPYRIGHT

Copyright 2011, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without 
modification, are permitted in any medium without royalty 
provided the copyright notice are preserved. This file is 
offered as-is, without any warranty.
