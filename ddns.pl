#!/usr/bin/perl
# nsupdate based ddns script, draft
#
# Copyright (c) 2011 - Olof Johansson <olof@cpan.org>
# All rights reserved.
# 
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself.

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
my $keyfile = '/dev/null';
my $ttl = 600;

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

	if(defined $addr && $addr =~ /^$RE{net}{IPv4}$/) {
		print "update add $host.$origin $ttl A $addr\n";
		#$nsupdate->add(
		#	name=>$host,
		#	type=>'A',
		#	data=>$addr,
		#);
		$exec = 1;
	}
}

if($extsrc6) {
	my $addr = get($extsrc6);

	if(defined $addr && $addr =~ /^$IPv6_re$/) {
		print "update add $host.$origin $ttl AAAA $addr\n";
		#$nsupdate->add(
		#	name=>$host,
		#	type=>'AAAA',
		#	data=>$addr,
		#);
		$exec = 1;
	}
}

if($exec) {
	#$nsupdate->execute();
}
