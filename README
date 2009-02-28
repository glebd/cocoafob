Generate private EC key
=======================

openssl ecparam -out ec.pem -name secp160k1 -genkey

Write public EC key
===================

openssl ec -in ecc.pem -pubout -out ecpub.pem

Convert DSA private key from PEM to DER format
==============================================

openssl dsa -inform PEM -outform DER -in dsapriv512.pem -out dsapriv512.der

Extract public key from private key
===================================

openssl dsa -in dsapriv512.pem -pubout -out dsapub512.pem

openssl dsa -in dsapriv512.der -pubout -out dsapub512.der -inform DER \
-outform DER

Credits
=======

The Base32 implementation is Copyright (C) 2007 by Samuel Tesla and comes from
Ruby base32 gem: http://rubyforge.org/projects/base32/. Samuel Tesla's blog is
at http://blog.alieniloquent.com/tag/base32/.
