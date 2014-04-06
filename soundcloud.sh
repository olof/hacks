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
[ -n "$WEB" ] || die 'Need to supply an URL'
TITLE="${WEB##*/}"

[ -n "$TITLE" ] || die "$WEB should not end with /"

STREAM=$(
	curl -A firefox -s "$WEB" | grep -F "$TITLE" |
		sed -ne 's/.*"streamUrl":"\([^"]\+\).*/\1/p'
)
[ -n "$STREAM" ] || die "Unable to find stream url in $WEB"

curl -Lo "$TITLE" "$STREAM"
mime=$(file --mime "$TITLE" | sed -r 's/^[^:]+: ([^;]+);.*/\1/')

# We default to assume mp3. Not sure if this is legit :)
ext=mp3
case $mime in
	audio/x-wav)
		ext=wav
		;;
esac

mv $TITLE $TITLE.$ext
echo "Download complete: $TITLE.$ext"
