# CocoaFob

## C++ implementation
Jaime O. Rios


## Introduction
This is the C++ port of CocoaFob, which allows for the same type of functionality Obj-C and Swift developers have, on any platform that supports C++.

## Requirements
* Catch C++ Unit Testing Header
* OpenSSL 1_0_2 stable release

### Git repos for libraries
* Catch Unit Testing: https://github.com/philsquared/Catch
   * Placed single_include header file into ./components/catch/include/
* OpenSSL 1_0_2 lib: git://git.openssl.org/openssl.git

### Download script
A bash shell script named download_required_libs.sh is in the same directory as this README file and can be used for downloading the required files (Catch, OpenSSL) from source and places the headers and binaries in the components directory.

