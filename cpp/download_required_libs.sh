#!/bin/bash

set -e
set -u

echo "Attempting to download "

if [[ ! -d components ]]; then
	echo "components/catch/include/ path not found; attempting to create directory"
	mkdir -p components/catch/include/

	echo "components/cryptopp/ path not found; attempting to create directory"
	mkdir -p components/cryptopp/
fi

echo "Attempting to get catch c++ unit testing single header file"
cd components/catch/include/
curl -O https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp 
cd ../../..


echo "Attempting to download cryptopp563 source and build libraries from source"
mkdir cryptopp563_src
cd cryptopp563_src
curl -O https://www.cryptopp.com/cryptopp563.zip
unzip cryptopp563.zip

echo "Building cryptopp563"
PREFIX=./xbuild_dir make
PREFIX=./xbuild_dir make install

echo "Moving output to components folder"
mv xbuild_dir/bin ../components/cryptopp/
mv xbuild_dir/include ../components/cryptopp/
mv xbuild_dir/lib ../components/cryptopp/

echo "Removing cryptopp563 source folder"
cd ..
rm -rf cryptopp563_src

echo "Download and install operation complete"