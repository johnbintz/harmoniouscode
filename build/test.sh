#!/bin/bash

./setup.sh
./regenerate_data_files.sh
haxe tests.hxml && neko ../neko/my_tests.n

