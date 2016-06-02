//
//  CFobLicVerifier.hpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#ifndef CFobLicVerifier_hpp
#define CFobLicVerifier_hpp

#include <memory>
#include <tuple>
#include <string>

#include <cryptopp/dsa.h>
using CryptoPP::DSA;

using ErrorMessage = std::string;
using RegCode      = std::string;
using UTF8String   = std::string;

auto CompletePublicKeyPEM(const UTF8String partialPEM) -> UTF8String;


class CFobLicVerifier
{
public:
    auto VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>;
    
private:
    template <typename T>
    friend T CreateCFobLicVerifier(const UTF8String partialPubKey );
    
    CFobLicVerifier(const UTF8String partialPubKey);
    
    CFobLicVerifier() = delete;
    const UTF8String _pubKey;
    
    DSA::PublicKey _dsaPubKey;
};


/*
 Factory function, which will check if the private key
 is valid before returning an instance to CFobLicGenerator.
 */
template <typename T = std::shared_ptr<CFobLicVerifier> >
T CreateCFobLicVerifier(const UTF8String partialPubKey )
{
    if (partialPubKey.length() == 0)
        return T{};
    
    auto verifier = T {new CFobLicVerifier(partialPubKey)};
    
    return verifier;
}


#endif /* CFobLicVerifier_hpp */
