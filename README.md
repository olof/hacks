A collection of small scripts, utilities, **hacks**.

## utils/: General command line utils

### atbl
Produce ascii tables for the terminal. See source code for input
format. Uses the Perl module Text::ASCIITable to render tables.

    $ atbl Title foo:bar:baz 1:2:3 4:5:6
    .-----------------.
    |      Title      |
    +-----+-----+-----+
    | foo | bar | baz |
    +-----+-----+-----+
    |   1 |   2 |   3 |
    |   4 |   5 |   6 |
    '-----+-----+-----'

### color-grep
Sort of like grep, but instead of omitting non-matching lines,
color-grep surrounds matching lines with terminal color codes
instead, making the line stand out while retaining its context.
Comes with a manual. Written in Perl.

### daterange
Calculate the duration (in days) between two dates.

    $ daterange 1970-01-01 2017-01-01
    17167

### hashsums-to-tree
Convert a hashsum list (as outputted by md5sum, sha1sum, etc. to
a list of files grouped by the content digest.

input:

    6ffd97154dba59c71f4059dbcccff151  ./foo
    98ca96b92091e8887455c61d3ba764f1  ./bar
    385cda1cb77b6f1fc6b33cd82bb2de24  ./baz
    385cda1cb77b6f1fc6b33cd82bb2de24  ./qux
    385cda1cb77b6f1fc6b33cd82bb2de24  ./quux

output:

    ---
    6ffd97154dba59c71f4059dbcccff151:
     - ./foo
    98ca96b92091e8887455c61d3ba764f1:
     - ./bar
    385cda1cb77b6f1fc6b33cd82bb2de24:
     - ./baz
     - ./qux
     - ./quux

### json2yaml, xml-simple2yaml
Convert JSON or XML to YAML for easier reading. Work like a
filters:

    curl -s "$url.json" | json2yaml | less
    curl -s "$url.xml" | xml-simple2yaml | less

(xml-simple2yaml uses XML::Simple, which has its weaknesses, but
allows for a trivial implementation of this tool.)

### rfc
Fetch and open up an ietf rfc in a pager. Also supports
internet drafts using the -d flag.

    $ rfc 1034

### shell-redirector
A PoC /bin/sh replacement that lets the user override the system
shell to use via the environment. If /bin/sh is provided by
/bin/dash by default, this wrapper make it possible to instead
use bash in a specific shell session by setting the environment
variable `INVOKE_SHELL` to `/bin/bash`, while still not
interfering with the normal behavior. Comes with a manual.
Written as a portable shell script.

### tar-nobomb
A PoC wrapper around tar to verify that an archive isn't a tar
bomb (i.e. with multiple files in the toplevel) before unpacking.

### uri-encode
URI encoding/decoding on the command line. Reads from stdin:

    $ echo -n '?/&' | uri-encode
    %3F%2F%26

Can be symlinked to as uri-decode to provide the reverse
behavior as well:

    $ echo -n %3F%2F%26 | uri-decode
    ?/&

Written in Perl, based on the URI::Encode module.

### wp-translate
Use wikipedia as a translation dictionary, by looking up the list
of corresponding articles in other languages.

    $ wp-translate en sv 'Machine translation'
    Maskinöversättning

## network/: Networking and DNS
### aslookup
Look up Autonomous System Number (ASN) of an IP address.

    $ aslookup 192.30.253.112
    "36459 | 192.30.253.0/24 | US | arin | 2012-11-15"

Relies on a public service provided by cymru.com.

### dnssec-dsfromdns
Generate a DS record from DNSKEY fetched over DNS.

    $ dnssec-dsfromdns iis.se
    $ iis.se. IN DS 18937 5 1 10DD1EFDC7841ABFDF630C8BB37153724D70830A
    $ iis.se. IN DS 18937 5 2 B5C422428DEA4137FBF15E1049A48D27FA5EADE64D2EC9F3B58A994A6ABDE543

    $ dnssec-dsfromdns github.com
    $ Error resolving or no DNSKEY. github.com not signed?

### pinggw
Ping your default gateway without having to look up its ip address.

### se_serial.sh
Compare cached serial for .se with authoritative data.

    $ se_serial.sh
    Cache is up to date with 2017071408

## devel/: Development utils

### cpan-release
Upload a new Perl module release to PAUSE (CPAN)

### git-wrapper
Make it possible to override specific git subcommands with shell
wrappers. Comes with a readme.

### gitignore
Download a gitignore file from Github using their gitignore
database.

    $ gitignore Perl >.gitignore

Running gitignore without parameters prints the list of available
gitignore templates (for the various supported
languages/development environments).

### locate_pm
Find location where a Perl module is installed.
