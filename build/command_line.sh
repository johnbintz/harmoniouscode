#!/bin/bash

./setup.sh
haxe command_line.hxml && neko ../neko/codeparser.n $1 $2 $3 $4 $5
