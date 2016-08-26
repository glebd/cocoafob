#!/bin/bash

set -e
set -u
#set -x

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

    cd $CFOB_CURRENT_PATH
}

function SetupCatch()
{
    if [[ ! -d components/catch/ ]]; then
        echo "*********************************"
        echo "${FUNCNAME[0]}"
        mkdir -p components/catch/include/
        cd components/catch/include/
        curl -O https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp
        cd $CFOB_CURRENT_PATH
        echo "*********************************"
    fi
}

function SetupOpenSSL()
{
    if [[ ! -d components/openssl ]]; then
        echo "*********************************"
        echo "${FUNCNAME[0]}"
        mkdir -p components/openssl_src
        cd components/openssl_src
        git clone -b OpenSSL_1_0_2-stable git://git.openssl.org/openssl.git
        cd openssl

        ./config --prefix=$PWD/macos_build_10.11 --openssldir=$PWD/macos_build_10.11/openssl
        make
        make test
        make -j 8 install

        cd ../..
        mv openssl_src/openssl/macos_build_10.11 ./openssl
        rm -fR openssl_src

        cd $CFOB_CURRENT_PATH
        echo "*********************************"
    fi
}

function SetupXcodeCoverage()
{
    if [[ ! -d components/XcodeCoverage/ ]]; then
        echo "*********************************"
        echo "${FUNCNAME[0]}"
        cd components/
        git clone https://github.com/jonreid/XcodeCoverage.git
        cd XcodeCoverage
        rm -fR .git
        rm .gitignore
        cd $CFOB_CURRENT_PATH
        echo "*********************************"
    fi
}



if [[ ! -d components ]]; then
    mkdir components/
fi

CFOB_CURRENT_PATH=$PWD

SetupCatch
SetupOpenSSL
SetupXcodeCoverage

echo "Download and install operation complete"
