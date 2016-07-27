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
#include <cryptopp/pem.h>



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
        
        PEM_Load(ss, pubKey);
        
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
    if(regCode.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty regCode string detected"});
    }
    
    if(forName.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty name string detected"});
    }
    
    try
    {
        auto regCodeTmp = regCode;
        // Replace 9s with Is and 8s with Os
        std::replace( regCodeTmp.begin(), regCodeTmp.end(), '9', 'I');
        std::replace( regCodeTmp.begin(), regCodeTmp.end(), '8', 'O');
        // Remove dashes from the registration key if they are there (dashes are optional).
        regCodeTmp.erase(std::remove(regCodeTmp.begin(), regCodeTmp.end(), '-'), regCodeTmp.end());
        
        auto verifier = CryptoPP::DSA::Verifier{ _dsaPubKey };
        auto message = forName;
        auto signature = regCodeTmp;
        CryptoPP::StringSource( message+signature, true,
                               new CryptoPP::SignatureVerificationFilter(
                                                                         verifier, nullptr,
                                                                         CryptoPP::SignatureVerificationFilter::THROW_EXCEPTION
                                                                         )
                               );
        
        return std::make_tuple(true, std::string("Verified signature on message"));
    }
    catch( CryptoPP::SignatureVerificationFilter::SignatureVerificationFailed& e )
    {
        auto errMsg = UTF8String{"SignatureVerificationFailed: "};
        errMsg += e.what();
        
        return std::make_tuple(false, errMsg);
    }
    catch( CryptoPP::Exception& e )
    {
        auto errMsg = UTF8String{"Exception caught: "};
        errMsg += e.what();
        
        return std::make_tuple(false, errMsg);
    }
        
    return std::make_tuple(false, std::string("Uknown error"));
}