#!/usr/bin/perl
use warnings;
use strict;
use Encode;

# This script renders exported Dustin carts in a prettier format.
# It works on the tab separated export format. Have fun.

my $tot = 0;

# "Swedish" price format. Ugh.
# 1 615,10 => 1615.10
sub price {
	local $_ = shift;
	s/,/./;
	s/\h//g;
	return $_;
}

<>; # skip the heading line
while (<>) {
	$_ = decode('UTF-8', $_); # they be doing some unicode trickery

	my ($count, $name, $id, $mfc_id,
	    $stock, $cost, $sum, $comment) = split /;/;

	$cost = price($cost);
	$tot += price($sum);

	print <<EOF
$name:
    Price:        $cost kr
    Count:        $count
    Stock status: $stock

    http://www.dustinhome.se/product/$id/

EOF
}

print "Total cost: $tot\n";
