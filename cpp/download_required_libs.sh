#!/bin/bash

set -e
set -u

echo "Attempting to download "

function CryptoppSetup()
{
	echo "Attempting to get catch c++ unit testing single header file"
	cd components/catch/include/
	curl -O https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp 
	cd ../../..


	echo "Attempting to download cryptopp563 source and build libraries from source"
	mkdir cryptopp563_src
	cd cryptopp563_src
	curl -O https://www.cryptopp.com/cryptopp563.zip
	unzip cryptopp563.zip

	echo 'Attempting to get PEM pack, required for PEM decoding'
	curl -O http://www.cryptopp.com/w/images/5/5a/Pem-pack.zip
	unzip Pem-pack.zip

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
}

function OpenSSLSetup()
{
	echo "Attempting to download openssl source and build libraries from source"
	mkdir openssl_src
	cd openssl_src
	
	git clone -b OpenSSL_1_0_2-stable git://git.openssl.org/openssl.git
}

function SetupXcodeCoverage()
{
	cd components/
#	git clone https://github.com/jonreid/XcodeCoverage.git
	curl -O https://github.com/jonreid/XcodeCoverage/archive/master.zip
	unzip master.zip
}

function MakeRequiredFolders()
{
	if [[ ! -d components ]]; then
		mkdir components/
	fi
	
	if [[ ! -d components/catch/ ]]; then
		echo "components/catch/include/ path not found; attempting to create directory"
		mkdir -p components/catch/include/
	fi

#	if [[ ! -d components/cryptopp/ ]]; then
#		echo "components/cryptopp/ path not found; attempting to create directory"
#		mkdir -p components/cryptopp/
#	fi

#	if [[ ! -d components/XcodeCoverage/ ]]; then
#		echo "components/XcodeCoverage/ path not found; attempting to create directory"
#		mkdir -p components/XcodeCoverage/
#	fi
}


MakeRequiredFolders
SetupXcodeCoverage

echo "Download and install operation complete"