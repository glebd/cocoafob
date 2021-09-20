//
//  CFobCrypto.hpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#ifndef CFobCrypto_hpp
#define CFobCrypto_hpp

#include <tuple>
#include "CFobDataTypes.hpp"

namespace CFob
{
    auto IsPublicKeyComplete(const UTF8String publicKey) -> bool;

    auto CompletePublicKeyPEM(const UTF8String partialPEM) -> UTF8String;

    auto CreateDSAPubKeyFromPublicKeyPEM(const UTF8String publicKey) -> std::tuple<bool, ErrorMessage, DSA*>;
}


#endif /* CFobCrypto_hpp */
