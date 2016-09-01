//
//  CFobLicVerifier.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CFobLicVerifier.hpp"
#include "CFobInternal.hpp"
#include <string>
#include <sstream>
#include <iostream>
#include <vector>
#include <openssl/engine.h>
#include <openssl/pem.h>

extern "C" {
#include "decoder.h"
}

CFobLicVerifier::CFobLicVerifier(DSA* pubKey, const UTF8String dsaPubKeyAsString)
: _dsaPubKey{pubKey, ::DSA_free}
, _dsaPubKeyAsString{dsaPubKeyAsString}
{
    ERR_load_crypto_strings();
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
    
    const auto strippedRegCode = CFob::Internal::StripFormattingFromBase32EncodedString(regCode);
    const auto decodedSize     = base32_decoder_buffer_size(strippedRegCode.length());
    
    auto sig           = std::vector<uint8_t>(decodedSize, 0);
    const auto sigSize = base32_decode(sig.data(),
                                       decodedSize,
                                       (unsigned char *)strippedRegCode.c_str(),
                                       strippedRegCode.length());
    
    auto digest = std::vector<uint8_t>(0, SHA_DIGEST_LENGTH);
    SHA1((unsigned char *)forName.data(), forName.length(), digest.data());
    
    const auto check = DSA_verify(0,
                                  digest.data(),
                                  digest.size(),
                                  sig.data(),
                                  (int)sigSize,
                                  _dsaPubKey.get());
    
    const auto result        = check > 0;

    std::ostringstream errMsg;
    errMsg << "Failed";
    if (!result)
        errMsg << ": " << ERR_error_string(ERR_get_error(), nullptr);

    const auto resultMessage = result ? UTF8String{"Verified"} : errMsg.str();
    
    return std::make_tuple(result, resultMessage);
}
