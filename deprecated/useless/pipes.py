#!/usr/bin/python3
import sys
import subprocess

class Data:
    "Ceci n'est pas une pipe"

    def __init__(self, data):
        self.data = data

    # the o in __or__ is actually the intersection of
    # a pipe segment, and the r is for, uh... (w)rench.
    def __or__(self, cmd):
        #print(f"[debug] {self.data}", file=sys.stderr)
        return __class__(cmd(self.data))

def sh(c, **kwargs):
    kwargs.setdefault('text', True)
    kwargs.setdefault('check', True)
    kwargs.setdefault('capture_output', True)
    kwargs.setdefault('shell', True)
    return lambda inp: subprocess.run(c, input=inp, **kwargs).stdout

# foobar -> B4R F00
Data(sys.argv[1]) \
| str.upper \
| (lambda x: [x[:len(x)//2], x[len(x)//2:]]) \
| reversed \
| ' '.join \
| sh("sed 'y/OA/04/'") \
| print
