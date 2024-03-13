Things i've written to keep my .mailcap somewhat tidy, and the
html emails/attachments somewhat ok looking when rendered.

I have something like:

```mailcap
text/html; sandbox-mailcap html-dump %{charset}; copiousoutput;
application/pdf; sandbox-mailcap pdftotext -nopgbrk - -; copiousoutput;
```

The scripts are run in a sandbox, using bwrap, it's not possible
to write to the filesystem and there is no network. This is
important for both HTML and PDF, as they attract talented
software craftsmen who would love to be able to run code on your
machine without your consent.

Currently, because of my sandbox hack, you need to install the
scripts to /usr/bin, or figure it out yourself, with permissions
and such.

The html renderer has a postprocessing script that among other
things shortens long urls. The details of the url shortener is
mostly uninteresting, and you can implement that yourself; it
takes a text/plain POST with a url and returns a short url if
succesful. If you don't specify a url to such a service, the
behavior is skipped (making the postprocessing mostly no-op,
except for some whitespace cleanup).

Dependencies:

* bubblewrap: sandboxing
* poppler-utils (pdftotext) - PDF rendering
* w3m - HTML rendering
