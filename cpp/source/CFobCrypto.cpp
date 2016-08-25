//
//  CFobCrypto.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CFobCrypto.hpp"

namespace CFob
{
    

auto CreateDSAPubKeyFromPublicKeyPEM(const UTF8String publicKeyPEM) -> std::tuple<bool, ErrorMessage, DSA*>
{
    if (publicKeyPEM.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty PEM string detected"}, nullptr);
    }
    
    const auto completeKey = IsPublicKeyComplete(publicKeyPEM) ? publicKeyPEM : CompletePublicKeyPEM(publicKeyPEM);
    
    return std::make_tuple(false, UTF8String{"Empty PEM string detected"}, nullptr);
}

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

} // CFob
