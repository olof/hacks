#!/usr/bin/perl
# nsupdate based ddns script, draft
#
# Copyright (c) 2011 - Olof Johansson <olof@ethup.se>
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself.

# Blocked by:
# * Net::Bind::Update needs to be completed
# 
# Dependencies:
# * LWP
# * Regexp::Common
# * Regexp::IPv6
# * (Net::Bind::Update) (unpublished, unfinished, etc)

use warnings;
use strict;
use LWP::Simple qw/get/;
#use Net::Bind::Update;
use Regexp::Common qw/net/;
use Regexp::IPv6 qw/$IPv6_re/;

my $host = 'asimov';
my $origin = 'ddns.x20.se.';
my $extsrc4 = 'http://ipv4.ethup.se/cgi-bin/ip.cgi';
my $extsrc6 = 'http://ipv6.ethup.se/cgi-bin/ip.cgi';
my $datadir = '/var/lib/nsddns';
my $keyfile = '/dev/null';
my $ttl = 600;

my $fh;
my ($ipv4, $ipv6);
open $fh, '<', "$datadir/current";
while(<$fh>) {
	my ($key, $val) = split /,/;
	$ipv4 = $val if $key eq 'ipv4';
	$ipv6 = $val if $key eq 'ipv6';
}
close $fh;

#my $nsupdate = Net::Bind::Update->new(
#	origin => $origin,
#	ttl => $ttl,
#	keyfile => $keyfile,
#);

my $exec = 0;
#$nsupdate->del(name=>$host);
print "update delete $host.$origin\n";

if($extsrc4) {
	my $addr = get($extsrc4);

	if(defined $addr && $addr =~ /^$RE{net}{IPv4}$/ && $addr ne $ipv4) {
		print "update add $host.$origin $ttl A $addr\n";
		$ipv4 = $addr;
		#$nsupdate->add(
		#	name=>$host,
		#	type=>'A',
		#	data=>$addr,
		#);
		$exec = 1;
	} else {
		$ipv4 = undef;
	}
} elsif(defined $ipv4) {
	$ipv4 = undef;
	$exec = 1;
}

if($extsrc6) {
	my $addr = get($extsrc6);

	if(defined $addr && $addr =~ /^$IPv6_re$/ && $addr ne $ipv6) {
		print "update add $host.$origin $ttl AAAA $addr\n";
		$ipv6 = $addr;
		#$nsupdate->add(
		#	name=>$host,
		#	type=>'AAAA',
		#	data=>$addr,
		#);
		$exec = 1;
	} else {
		$ipv6 = undef;
	}
} elsif(defined $ipv6) {
	$ipv6 = undef;
	$exec = 1;
}

if($exec) {
	#$nsupdate->execute() or die("oops");

	open $fh, '>', "$datadir/current";
	print "ipv4,$ipv4" if defined $ipv4;
	print "ipv6,$ipv6" if defined $ipv6;
}

