#!/bin/bash

if [ -z $1 ]; then
  echo "Need to specify a phpdoc directory"
  exit 1
fi

if [ ! -e $1 ]; then
  echo "Provided phpdoc directory $1 not found"
  exit 1
fi

if [ ! -d $1 ]; then
  echo "Provided phpdoc directory $1 is not a directory."
  exit 1
fi

./setup.sh
cd ../data
rm phpdoc_*

ln -s $1/phpbook/phpbook-xsl/version.xml phpdoc_function_versions.xml

for constant_file in $(find $1/en/reference -name "constants.xml" -exec grep -L "no.constants" {} \;) ; do
  echo $constant_file
  constant_module=$(expr "$constant_file" : '.*/reference/\(.*\)/')
  ln -s $constant_file "phpdoc_constants_${constant_module}.xml";
done