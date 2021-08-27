//
//  CFobCrypto.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CocoaFob/CFobCrypto.hpp"

#import <openssl/evp.h>
#import <openssl/err.h>
#import <openssl/pem.h>

namespace CFob
{
    

auto CreateDSAPubKeyFromPublicKeyPEM(const UTF8String publicKeyPEM) -> std::tuple<bool, ErrorMessage, DSA*>
{
    if (publicKeyPEM.length()==0)
    {
        return std::make_tuple(false, UTF8String{"Empty PEM string detected"}, nullptr);
    }
    
    const auto completeKey = IsPublicKeyComplete(publicKeyPEM) ? publicKeyPEM : CompletePublicKeyPEM(publicKeyPEM);
    
    auto bio    = BIO_MEM_uptr{BIO_new_mem_buf((void *)completeKey.c_str(), -1), ::BIO_free};
    auto dsa    = DSA_new();
    auto result = PEM_read_bio_DSA_PUBKEY(bio.get(), &dsa, NULL, NULL);
#if (0)
    if (result != nullptr)
    {
        return std::make_tuple(true, UTF8String{"Success"}, dsa);
    }
    else
    {
#if defined(DEBUG)
        ERR_print_errors_fp(stdout);
#endif
        return std::make_tuple(false, UTF8String{"Error detected"}, nullptr);
    }
#else
    (void)result;
    return std::make_tuple(true, UTF8String{"Success"}, dsa);
#endif
}

auto IsPublicKeyComplete(const UTF8String publicKey) -> bool
{
    auto found = publicKey.find(std::string{"-----BEGIN DSA PUBLIC KEY-----"});
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
