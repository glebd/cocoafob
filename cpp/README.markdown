# CocoaFob

## C++ implementation
Jaime O. Rios


## Introduction
This is the C++ port of CocoaFob, which allows for the same type of functionality Obj-C and Swift developers have, on any platform that supports C++.

## Requirements
* Catch C++ Unit Testing Header
* Crypto++ 5.6.3 lib 
* Crypto PEM Pack (http://www.cryptopp.com/wiki/Pem_pack)

### Git repos for libraries
* Catch Unit Testing: https://github.com/philsquared/Catch
   * Placed single_include header file into ./components/catch/include/
* Crypto++ 5.6.3 lib: https://www.cryptopp.com/
   * Place binary into into ./components/cryptopp/

### Download script
A bash shell script named download_required_libs.sh is in the same directory as this README file and can be used for downloading the required files, which builds the crypto library from source and places the headers and binaries in the components directory.

### Additional notes
As of the writing of this xcconfig file, the development machine was MacOS 10.11.3 (15D21)
which means that OpenSSL is not available in the native SDK as a framework.

To get around this problem, openssl 0.9.8 was downloaded (git://git.openssl.org/openssl.git)
and compiled for MacOS at the OpenSSL_0_9_8-stable branch (commit 89133ba26a1c9e0fa99dd2cc782fa504ea3a5137)

You can install the openssl libraries in your system or you can install into a custom build directory
using ./config --prefix=./build/openssl , as an example

In my case, I built using the following config command: ./config --prefix=./macos_build_10.11
then copied my binaries into a lib directory in the root of the project folder