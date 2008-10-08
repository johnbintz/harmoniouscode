#!/bin/bash

for dir in neko data; do
  if [ ! -e "../${dir}" ]; then mkdir "../${dir}" 2>&1; fi
done
