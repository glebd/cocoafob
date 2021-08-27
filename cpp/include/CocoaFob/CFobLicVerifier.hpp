//
//  CFobLicVerifier.hpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#ifndef CFobLicVerifier_hpp
#define CFobLicVerifier_hpp

#include "CFobCrypto.hpp"

class CFobLicVerifier
{
public:
    auto VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>;
    
private:
    template <typename T>
    friend T CreateCFobLicVerifier(const UTF8String publicKey );
    
    CFobLicVerifier(DSA* pubKey, const UTF8String dsaPubKeyAsString);
    
    CFobLicVerifier() = delete;
    
    std::unique_ptr<DSA, decltype(&::DSA_free)> _dsaPubKey;
    const UTF8String _dsaPubKeyAsString;
};


/*
 Factory function, which will check if the private key
 is valid before returning an instance to CFobLicGenerator.
 */
template <typename T = std::shared_ptr<CFobLicVerifier> >
T CreateCFobLicVerifier(const UTF8String publicKey )
{
    if (publicKey.length() == 0)
        return T{};
    
    auto dsaKeyResult = CFob::CreateDSAPubKeyFromPublicKeyPEM(publicKey);
    
    const auto success = std::get<0>(dsaKeyResult);
    const auto reason  = std::get<1>(dsaKeyResult);
    (void)reason; // for debugging purposes
    
    if (success)
    {
        auto pubKey = std::get<2>(dsaKeyResult);
        auto verifier = T {new CFobLicVerifier(pubKey, CFob::CompletePublicKeyPEM(publicKey))};
        
        return verifier;
    }
    else
    {
        return T{};
    }
}


#endif /* CFobLicVerifier_hpp */
