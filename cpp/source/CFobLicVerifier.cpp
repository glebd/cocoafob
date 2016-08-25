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

CFobLicVerifier::CFobLicVerifier(DSA* pubKey, const UTF8String dsaPubKeyAsString)
: _dsaPubKey{pubKey}
, _dsaPubKeyAsString{dsaPubKeyAsString}
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
    
    return std::make_tuple(false, std::string("Uknown error"));
}