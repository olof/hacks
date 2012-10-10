#!/bin/sh
# helper functions for unit tests

TMPDIR=
TEST_OLDPATH=

test_init() {
	test_workdir
	[ -z "$1" ] || [ "$1" != managed ] || test_cleanup_trap
}

test_cleanup_trap() {
	trap test_cleanup EXIT
}

test_die() {
	echo "Error:" "$@" >&2
	exit 1
}

test_workdir() {
	TMPDIR=$(mktemp -d /tmp/hacks_unittests-XXXXXX)
	[ "$TMPDIR" ] || test_die "mktemp failed":
	[ -d "$TMPDIR" ] || test_die "mktemp didn't create '$TMPDIR'"
	TEST_OLDPATH=$PWD
	cd $TMPDIR || test_die "could not cd to $TMPDIR"
}

test_cleanup() {
	[ "$TMPDIR" ] || return 0
	case $TMPDIR in
		/tmp/hacks_unittests-*)
			rm -rf $TMPDIR
			;;
	esac
}
