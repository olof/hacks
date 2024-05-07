I discovered having written this and having it lay around
uncommited. Declarative argparsing, inspired by Python's
argparse. But in shell. Such a weird hack. I like it. Can't
exactly remember what the abbreviation stands for...

* Olof's Strange Shell Experiment?
* OSSE Shell Scripting Environment?

Take a look at `wikt` for an example (which doesn't work very
well, I might add, but it's a good example):

```shell
#!/usr/bin/env osse
arguments init --name wikt --version 0.1 \
	--description "Wiktionary command line client."
arguments add language --short l \
	--type store --dest lang --default English \
	--description "Language of word"
arguments add list-languages --short L \
	--type bool --dest list_langs \
	--description "List languages availabe for word"
arguments add mediawiki --short m \
	--type store --dest site --default https://en.wiktionary.org \
	--metavar url --description "Mediawiki site to query"
arguments add word --type pos \
	--dest word \
	--required \
	--help "Word"
arguments eval "$@"

case $site in
	http://*|https://*) ;;
	??|???) site=https://$site.wiktionary.org ;;
	*://*) die "Unsupported URI scheme ${site%%://*} for -m" ;;
	'') die "Why is site missing?" ;;
	*) site=https://$site ;;
esac

# This doesn't work very well, so don't worry about this.
#   "It's not about the money, herr Månsson, it's the principles."
selector='#content #firstHeading, .mw-parser-output .disambig-see-also'
[ "$list_langs" != y ] ||
	selector="$selector, .mw-parser-output h2 .mw-headline"

selector-scrape "$site/wiki/$word" "$selector"
```

Fiddle a little with `$PATH` to try it out without installing it:

```shell
# The utils/ directory is needed because of the selector-scrape
# script. If you already have it installed in your PATH you can
# skip that.
PATH=$PATH:$PWD/../utils:$PWD ./wikt --help
```

The environment also includes some utilities, currently:

 * die, prints a supplied error message and exits process with 1
 * witch, a shell port of which (maybe i should rename to whish?)
