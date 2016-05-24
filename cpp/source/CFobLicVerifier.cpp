//
//  CFobLicVerifier.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CFobLicVerifier.hpp"

auto CFobLicVerifier::VerifyRegCodeForName(const UTF8String regCode, const UTF8String forName) -> std::tuple<bool, ErrorMessage>
{
    return std::make_tuple(false, std::string(""));
}