#!/bin/sh
# compare cached serial for .se with auth

die() {
	echo Error: "$@" 1>&2
	exit 1
}

result() {
	echo "$@"
	exit 0
}

AUTH=$(dig +short SOA se. | awk '{print $3}')
CACHED=$(dig @a.ns.se. +short SOA se. | awk '{print $3}')

[ "$AUTH" ] || die 'Could not look up authoritative serial'
[ "$CACHED" ] || die 'Could not look up cached serial'

[ "$AUTH" -eq "$CACHED" ] 2>/dev/null &&
	result "Cache is up to date with $AUTH"
[ "$AUTH" -gt "$CACHED" ] 2>/dev/null &&
	result  "Cache is stale (auth:$AUTH, cache:$CACHED)"
[ "$AUTH" -lt "$CACHED" ] 2>/dev/null &&
	result "Cache is in the futuare :-) (auth:$AUTH, cache:$CACHED)"

die "Arithmetic comparisons failed. AUTH='$AUTH' CACHED='$CACHED'"
