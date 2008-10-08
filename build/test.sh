#!/bin/bash

./setup.sh
haxe tests.hxml && neko ../neko/my_tests.n

