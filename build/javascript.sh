#!/bin/bash

./setup.sh
haxe -cp ../src -neko ../neko/regenerate.n -main RegenerateDataFiles && neko ../neko/regenerate.n
rm ../htdocs/harmoniouscode.js
haxe javascript.hxml
