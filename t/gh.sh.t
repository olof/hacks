#!/bin/sh

UNIT_TEST=y

. ./t/lib/test-helpers.sh
. ./t/lib/tap.sh
. ./gh

test_init managed

#######
### die
#######
!(die "danger, danger!") 2>/dev/null
ok $? "die() exits with failure"

die_out=$(die "danger, danger!" 2>&1)
is "$die_out" "Error: danger, danger!" "expected die() output"

#################
### gh_url_author
#################
author=$(gh_url_author "git@github.com:olof/hacks.git")
is "$author" olof "Extract author from implict ssh url"
author=$(gh_url_author "ssh://git@github.com:olof/hacks.git")
is "$author" olof "Extract author from explicit ssh url"
author=$(gh_url_author "http://github.com/olof/hacks.git")
is "$author" olof "Extract author from http url"
author=$(gh_url_author "git://github.com/olof/hacks.git")
is "$author" olof "Extract author from http url"

done_testing

