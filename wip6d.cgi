#!/usr/bin/perl
# Copyright 2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

use warnings;
use strict;
use CGI qw/remote_addr/;
use Regexp::IPv6 qw/$IPv6_re/;

my $day6 = "Happy World IPv6 Day (2011-06-08)!";

my $msg = "Your ISP is not ready for IPv6! Time is running out. Act now!";
my $color = 'red';
my $ip = 'ipv4';

my $addr = remote_addr();

if($addr and $addr =~ /$IPv6_re/) {
	$msg = "Grats! You're safe! You're ISP is and you are ready for IPv6!";
	$color = 'green';
	$ip = 'ipv6';
}

print CGI->header();
printf join('', <DATA>), $day6, $color, $day6, $msg, ($ip)x3;

__DATA__
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>
 <head>
  <meta http-equiv='Content-Type' content='text/html;charset=UTF-8' />
  <title>ethup.se: %s</title>
  <style type="text/css">
   body { font-family: sans-serif; text-align: center; }
   h1 { font-size: 20px; }
   h2 { font-weight: bold; color: %s; }
  </style>
 </head>

 <body>
  <div id="cont">
   <h1>%s</h1>
   <h2>%s</h2>
   <img src="/img/%s.png" alt="%s" title="%s" />
  </div>
 </body>
</html>
