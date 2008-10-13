#!/bin/bash

./setup.sh
./regenerate_data_files.sh
rm ../htdocs/harmoniouscode.js
haxe javascript.hxml
