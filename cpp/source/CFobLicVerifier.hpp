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

using ErrorMessage = std::string;
using RegCode      = std::string;
using UTF8String   = std::string;

class CFobLicVerifier;

/*
 Factory function, which will check if the private key
 is valid before returning an instance to CFobLicGenerator.
 */
template <typename T = std::shared_ptr<CFobLicVerifier> >
T CreateCFobLicVerifier(const UTF8String publicKey )
{
    if (publicKey.length() == 0)
        return T{};
    
    return T{};
}


class CFobLicVerifier
{
public:
    auto VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>;
    
private:
    template <typename T>
    friend T CreateCFobLicVerifier(const UTF8String publicKey );
    
    CFobLicVerifier(const UTF8String publicKey);
    
    CFobLicVerifier() = delete;
    const UTF8String _pubKey;
};


#endif /* CFobLicVerifier_hpp */
