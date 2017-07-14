#!/bin/sh

# The sunet lossy text encoding

#      "Our carrier has announced fiber repair
#                      works between Eslvv and Hdssleholm."

[ -z "$@" ] && sed -e 'y/åäö/edv/' || echo "$@" | sed -e 'y/åäö/edv/'
