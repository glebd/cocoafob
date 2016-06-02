//
//  CFobLicVerifier.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CFobLicVerifier.hpp"
#include <string>

#include <cryptopp/cryptlib.h>
#include <cryptopp/filters.h>
using CryptoPP::StringSource;



auto CompletePublicKeyPEM(const UTF8String partialPEM) -> UTF8String
{
    using namespace std::string_literals;

    const auto dashes = "-----"s;
    const auto begin  = "BEGIN"s;
    const auto end    = "END"s;
    const auto key    = "KEY"s;
    const auto pub    = "DSA PUBLIC"s;
    
    auto pem = dashes;
    
    pem += begin;
    pem += " "s;
    pem += pub;
    pem += " "s;
    pem += key;
    pem += dashes;
    pem += "\n"s;
    pem += partialPEM;
    pem += dashes;
    pem += end;
    pem += " "s;
    pem += pub;
    pem += " "s;
    pem += key;
    pem += dashes;
    pem += "\n"s;
    
    return pem;
}

CFobLicVerifier::CFobLicVerifier(const UTF8String partialPubKey)
:  _dsaPubKey{DSA::PublicKey{}}
{
    const auto completeKey = CompletePublicKeyPEM(partialPubKey);
    
    auto&& ss = StringSource(completeKey, true /*pumpAll*/);
    _dsaPubKey.Load(ss);
}

auto CFobLicVerifier::VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>
{
    return std::make_tuple(false, std::string(""));
}