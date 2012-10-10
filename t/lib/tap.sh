#!/bin/sh
# TAP producer; meant to be sourced in 

TAP_TEST=0        # the current test number
TAP_PLAN=         # the planned number of tests

diag() {
	echo '#' "$@"
}

plan() {
	TAP_PLAN=$1
	echo 1..$TAP_PLAN
}

done_testing() {
	plan $TAP_TEST
}

pass() {
	__tap_test_line ok "$@"
}

fail() {
	__tap_test_line 'not ok' "$@"
}

is() {
	local output="$1"
	local ref="$2"
	local descr="$3"

	if [ "$output" = "$ref" ]; then
		pass "$descr"
	else
		fail "$descr"
		diag " Got: $output"
		diag " Expected: $ref"
	fi
}

isnt() {
	local output="$1"
	local ref="$2"
	local descr="$3"

	[ "$output" != "$ref" ]
	ok $? "$3"
}

ok() {
	local ret="$1" descr="$2"
	if [ $ret -eq 0 ]; then
		pass "$2"
	else
		fail "$2"
	fi
}

__tap_test_line() {
	local status="$1" descr="$2"
	TAP_TEST=$((TAP_TEST + 1))
	printf "%s %d - %s\n" "$status" $TAP_TEST "$descr"
}

return 1;
