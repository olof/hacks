#!/bin/sh
die() { error "$@"; exit 1; }
error() { echo ERROR: "$@" >&2; }

case "${1#*.}" in
	se|nu) ;;
	*) die unsupported tld, i suppose '(should work with .se and .nu)' >&2
esac

while :; do
	printf "%s: %s\n" \
		"$(date +%Y-%m-%dT%H:%M)" \
		"$(whois "$1" | grep -e ^state: -e '^domain ')"
	sleep ${INTERVAL:-3600} || exit 1
done
