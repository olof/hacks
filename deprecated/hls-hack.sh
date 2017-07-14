#!/bin/sh -e

die() { echo "Error:" "$@" >&2; exit 1; }
clean() { [ ! -e $M3U ] || rm $M3U; }

URL=$1
OUT=$2
[ "$URL" ] || die "No url supplied"
[ "$OUT" ] || die "No output filename supplied"
[ ! -e "$OUT" ] || die "Output file already exists"

M3U=$(mktemp /tmp/hls-hack.m3u8-XXXXXX)
[ -e "$M3U" ] || die "Could not create temp file"
trap clean EXIT

curl -s "$URL" | grep ^http >$M3U

COUNT=$(wc -l <$M3U)
[ "$COUNT" -gt 0 ] || die "Not a valid m3u file"

N=1
while read url; do
	echo "Downloading chunk $N/$COUNT"
	curl "$url" >>"$OUT"
	N=$((N+1))
done <$M3U
