A collection of small scripts, utilities, **hacks**.

## utils/: General command line utils

### a68

Generate numerical abbreviations, for whatever reason. Maybe you
want to work at a search company or something.


```console
$ a68 localization
l10n
$ a68 kubernetes
k8s
$ a68 abbreviate
a8e
$ a68 abbrevi8
a68
```

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

### find+

`find` preprocessor with brace expansion support.

`find+` is designed to preprocess `find` lines, with its flag based
language for selecting and operating on files. It will by default exec
"find", using PATH lookup, but this can be overriden by setting the
environment variable `FIND`.

Usage examples:

```console
$ find+ -type f -name 'f{inn,em,el}...'
# same as:
$ find -type f \( -name finn... -o -name fem... -o name fel... \)
```

```console
$ find+ -type f -name '{a,b}{1,2}'
# same as:
$ find -type f ( -name a1 -o -name a2 -o -name b1 -o -name b2 )
```

For interactive usage, you could alias find+ as find, but be aware
that doing so will make taking such a command and using it in a script
harder. Don't alias find+ as find in non-interactive environments, since
that will impact scripts not aware of find+ and might lead to rare but
very hard to diagnose bugs.

Probably don't use find+ in scripts, since that will add a dependency
to find+ - think of it more as an interactive convenience. If you do,
probably just call it as find+ to make this dependency explicit. Instead
of doing that, you could use find+ to expand a find line for you, by
making find+ call echo instead of find:

```console
$ FIND=echo find+ -name '{foo,bar}'
( -name foo -o -name bar )
```

The output can safely and portably be used in your shell scripts.

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

### json2line
A jq script to convert a JSON to a line based format.

    {
      "foo": "bar",
      "baz": {
        "lala": [
          {"qux": "xxxx"},
          {"kalle": "boll"}
        ]
      },
      "quux": [0, 1, 3, 4],
      "quuuuuux": 1
    }

into

    foo=bar
    baz/lala/0/qux=xxxx
    baz/lala/1/kalle=boll
    quux/0=0
    quux/1=1
    quux/2=2
    quux/3=3
    quux/4=4
    quuuuuux=1

Called like:

    $ json2line foo.json
    $ json2line <foo.json

    # To use an alternative delimiter, you can do:
    $ json2line --arg delim \\ foo.json

### markdown-autolinks

When using the reference syntax for links in markdown, you define
the reference definition separately from its usage. If we follow
some conventions, we can automate this process for commonly used
reference sources like Wikipedia or arXiv.

Running this script on a markdown file with undefined sources
matching the id pattern [prefix:page], this script will automatically
generate the URLs and append it to the output. Given the following
input:

    Here is a [link][wp:Foo].

The script will produce the following output:

    Here is a [link][wp:Foo].

    [wp:Foo]: https://en.wikipedia.org/wiki/Foo

### rfc
Fetch and open up an ietf rfc in a pager. Also supports
internet drafts using the -d flag.

    $ rfc 1034

### selector-scrape

Scrape content from web pages using css selectors.

```
$ selector-scrape https://en.wikipedia.org/wiki/List_of_HTTP_status_codes 'dl > dt'
100 Continue
101 Switching Protocols
102 Processing (WebDAV; RFC 2518)
103 Early Hints (RFC 8297)
200 OK
201 Created
202 Accepted
203 Non-Authoritative Information (since HTTP/1.1)
204 No Content
...
```

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

### unicodize-box
Convert your shabby ascii boxes to unicode. Reads from stdin or takes a
filename as a parameter. Filters the file and looks for boxes of "-" and
"|" characters. Should not touch those characters when they are not a
part of a box.

Try the script by running it on itself. There's some shabby ascii boxes
at the bottom.

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

### wt-translate
Use wiktionary as a multi translation lookup. It currently only
supports looking up English words (it should be easy to add
support for language selection, and even easier to just override
locally if you ever need to). The following output is abbreviated
for illustrative purposes:

    $ wt-translate 'machine translation'
    act of translating something by means of a machine

    Finnish: koneellinen kääntäminen, konekääntäminen
    Esperanto: maŝintradukado, maŝintraduko
    Japanese: 機械翻訳 (ja) (きかいほんやく, kikai hon'yaku)
    Polish: tłumaczenie maszynowe n
    Swedish: maskinöversättning (sv) c
    Ukrainian: машинний переклад m (mašynnyj pereklad)

    act of translating a computer language

    Finnish: konekielelle kääntäminen
    Japanese: コンピュータ言語の翻訳 (konpyūta gengo no hōnyaku)
    Polish: tłumaczenie języka programowania n
    Ukrainian: машинний переклад m (mašynnyj pereklad)

This depends on scraping CSS selectors; that's not really a
stable API, so please let me know if it breaks. This is intended
to be used interactively at low rate; it is not intended to be
used at scale. Use proper APIs for that.

The script assumes `selector-scrape` (available in this repo) is
present in `$PATH`, as well as its (Python) dependencies.

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

### http-codes
Filterable list of http codes.

    $ http-codes
    <lists all codes, with their meaning>

    $ http-codes 200
    200 OK

    $ http-codes OK
    200 OK
    498 Invalid Token (Esri)
    499 Token Required (Esri)

    $ http-codes '\bOK\b'
    200 OK

Data taken from wikipedia (see source code for details).

### pinggw
Ping your default gateway without having to look up its ip address.

### se_serial.sh
Compare cached serial for .se with authoritative data.

    $ se_serial.sh
    Cache is up to date with 2017071408

### se-state.sh

Regularly check the state of an .se/.nu domain. For reasons.

## devel/: Development utils

### cpan-release
Upload a new Perl module release to PAUSE (CPAN)

### git-pkt-prefix
Git pkt protocol line prefixing (strlen in hex)

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
