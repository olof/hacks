#!/usr/bin/perl
# Copyright 2013, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

use 5.014;
use warnings;

my @stack;
my %ops = (
	'+' => [2, sub { $_[0] + $_[1] }],
	'-' => [2, sub { $_[0] - $_[1] }],
	'*' => [2, sub { $_[0] * $_[1] }],
	'/' => [2, sub { $_[0] / $_[1] }],
	'**' => [2, sub { $_[0] ** $_[1] }],
);

sub take {
	my $n = shift;
	return splice @stack,-$n;
}

sub runop {
	my $op = shift;

	if (exists $ops{$op}) {
		my ($n, $sub) = @{$ops{$op}};

		if (@stack < $n) {
			warn "Too few operands on stack!\n";
			return;
		}
		push @stack, $sub->(take($n));
	} else {
		warn "Unknown operator: $op\n";
	}
}

while(<>) {
	chomp;
	for my $tok (split / /) {
		if ($tok =~ /^\d+(?:\.\d+)?$/) {
			push @stack, $tok;
			next;
		}

		runop($tok);
	}

	say $stack[$#stack];
}
