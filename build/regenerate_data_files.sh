#!/bin/bash

haxe -cp ../src -main RegenerateDataFiles -neko ../neko/regenerate.n && neko ../neko/regenerate.n

