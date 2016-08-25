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

#include <openssl/engine.h>
#include <openssl/pem.h>

auto IsPublicKeyComplete(const UTF8String publicKey) -> bool
{
    auto found = publicKey.find(std::string{"-----BEGIN PUBLIC KEY-----"});
    return found != std::string::npos;
}


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

auto CreateDSAPubKeyFromPublicKeyPEM(const UTF8String publicKeyPEM) -> std::tuple<bool, ErrorMessage, DSA*>
{
    if (publicKeyPEM.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty PEM string detected"}, nullptr);
    }
    
    const auto completeKey = IsPublicKeyComplete(publicKeyPEM) ? publicKeyPEM : CompletePublicKeyPEM(publicKeyPEM);
    
   return std::make_tuple(false, UTF8String{"Empty PEM string detected"}, nullptr);
}


CFobLicVerifier::CFobLicVerifier(DSA* pubKey, const UTF8String dsaPubKeyAsString)
: _dsaPubKey{pubKey}
, _dsaPubKeyAsString{dsaPubKeyAsString}
{
    ;
}


auto StripFormattingFromBase32EncodedString(UTF8String stringToFormat) -> UTF8String
{
    // Replace 9s with Is and 8s with Os
    std::replace( stringToFormat.begin(), stringToFormat.end(), '9', 'I');
    std::replace( stringToFormat.begin(), stringToFormat.end(), '8', 'O');
    
    // Remove dashes from the registration key if they are there (dashes are optional).
    stringToFormat.erase(std::remove(stringToFormat.begin(),
                                     stringToFormat.end(),
                                     '-'),
                         stringToFormat.end());
    
    return stringToFormat;
}

auto FormatBase32EncodedString(UTF8String stringToFormat) -> UTF8String
{
    // Replace 9s with Is and 8s with Os
    std::replace( stringToFormat.begin(), stringToFormat.end(), 'I', '9');
    std::replace( stringToFormat.begin(), stringToFormat.end(), 'O', '8');
    
    // Remove dashes from the registration key if they are there (dashes are optional).
    stringToFormat.erase(std::remove(stringToFormat.begin(),
                                     stringToFormat.end(),
                                     '='),
                         stringToFormat.end());
    
    auto index      = 5;
    const auto dash = UTF8String{"-"};
    while(index < stringToFormat.length())
    {
        stringToFormat.insert(index, dash);
        index += 6;
    }
    return stringToFormat;
}



auto CFobLicVerifier::VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>
{
    if(regCode.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty regCode string detected"});
    }
    
    if(forName.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty name string detected"});
    }
    
    return std::make_tuple(false, std::string("Uknown error"));
}