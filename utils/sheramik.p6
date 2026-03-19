#!/usr/bin/raku
my $DEFAULT_PS1 = '> ';

grammar PS1 {
    token TOP { <op>* }
    token op { [<esc> | <literal>] }
    proto token esc {*}
          token esc:sym<host>  { \\h }
          token esc:sym<user>  { \\u }
          token esc:sym<path>  { \\w }
          token esc:sym<flair> { \\\$ }
          token esc:sym<verb>  { \\ <literal> }
    token literal { . }
}

class PS1Resolver {
     method TOP ($/) { make ($/<op>».made).join }
     method op ($/) { make $/<esc> ?? $/<esc>.made !! $/<literal>.made }

     method esc:sym<host>  ($/) { make Kernel.hostname }
     method esc:sym<user>  ($/) { make %*ENV<LOGNAME> // '(unknown)' }
     method esc:sym<path>  ($/) { make %*ENV<PWD>.subst(/^ "%*ENV<HOME>/"/, "~/") }
     method esc:sym<flair> ($/) { make '$' }
     method esc:sym<verb>  ($/) { make $/<literal>.made }

     method literal ($/) { make $/ }
}

PS1.parse(%*ENV<PS1> // $DEFAULT_PS1, actions => PS1Resolver).made.print;

for lines() {
	shell($_);
	PS1.parse(%*ENV<PS1> // $DEFAULT_PS1, actions => PS1Resolver).made.print;
}
