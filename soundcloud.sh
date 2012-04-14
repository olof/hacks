#!/bin/sh
# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

# Depends on curl

die() {
	echo Error: "$@" >&2
	exit 1
}

WEB=$1
[ -n "$WEB" ] || die 'Need to supply a URL'
TITLE="${WEB##*/}"

[ -n "$TITLE" ] || die "$WEB should not end with /"

STREAM=$(
	curl -s "$WEB" | grep -F "$TITLE" | 
		sed -ne 's/.*"streamUrl":"\([^"]\+\).*/\1/p'
)
[ -n "$STREAM" ] || die "Unable to find stream url in $WEB"

curl -Lo "$TITLE.mp3" "$STREAM"
