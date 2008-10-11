#!/bin/sh

if [ ! -e ../doc ]; then mkdir ../doc; fi
haxe -cp ../src -xml ../doc/harmoniouscode.xml CommandLineInterface JavaScriptTarget
cd ../doc
haxedoc harmoniouscode.xml
