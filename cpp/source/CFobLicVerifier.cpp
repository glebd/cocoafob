//
//  CFobLicVerifier.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CFobLicVerifier.hpp"
#include <string>
#include <iostream>

#include <cryptopp/cryptlib.h>
#include <cryptopp/filters.h>
//using CryptoPP::StringSource;



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

auto CreateDSAPubKeyFromPartialPubKeyPEM(const UTF8String partialPEM) -> std::tuple<bool, ErrorMessage, CryptoPP::DSA::PublicKey>
{
    if (partialPEM.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty PEM string detected"}, CryptoPP::DSA::PublicKey{});
    }
    
    const auto completeKey = CompletePublicKeyPEM(partialPEM);
    
    try
    {
        auto&& ss = CryptoPP::StringSource(completeKey, true /*pumpAll*/);
        auto pubKey = CryptoPP::DSA::PublicKey{};
        pubKey.Load(ss);
        
        return std::make_tuple(true, UTF8String{"Success"}, pubKey);
    }
    catch( CryptoPP::Exception& e )
    {
        return std::make_tuple(false, UTF8String{e.what()}, CryptoPP::DSA::PublicKey{});
    }
}

CFobLicVerifier::CFobLicVerifier(CryptoPP::DSA::PublicKey pubKey)
:  _dsaPubKey{pubKey}
{
    ;
}

auto CFobLicVerifier::VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>
{
    return std::make_tuple(false, std::string(""));
}