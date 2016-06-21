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
//using CryptoPP::DSA;

using ErrorMessage = std::string;
using RegCode      = std::string;
using UTF8String   = std::string;

auto CompletePublicKeyPEM(const UTF8String partialPEM) -> UTF8String;
auto CreateDSAPubKeyFromPartialPubKeyPEM(const UTF8String partialPEM) -> std::tuple<bool, ErrorMessage, CryptoPP::DSA::PublicKey>;

class CFobLicVerifier
{
public:
    auto VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>;
    
private:
    template <typename T>
    friend T CreateCFobLicVerifier(const UTF8String partialPubKey );
    
    CFobLicVerifier(CryptoPP::DSA::PublicKey pubKey);
    
    CFobLicVerifier() = delete;
    //const UTF8String _pubKey;
    
    CryptoPP::DSA::PublicKey _dsaPubKey;
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
    
    auto dsaKeyResult = CreateDSAPubKeyFromPartialPubKeyPEM(partialPubKey);
    
    const auto success = std::get<0>(dsaKeyResult);
    const auto reason  = std::get<1>(dsaKeyResult);
    (void)reason; // for debugging purposes
    
    if (success)
    {
        auto pubKey = std::get<2>(dsaKeyResult);
        auto verifier = T {new CFobLicVerifier(pubKey)};
        
        return verifier;
    }
    else
    {
        return T{};
    }
}


#endif /* CFobLicVerifier_hpp */
