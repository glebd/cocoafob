//
//  CFobLicGenerator.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-17.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "CocoaFob/CFobLicGenerator.hpp"

CFobLicGenerator::CFobLicGenerator(const std::string privateKey)
: _privateKey(privateKey)
{
    ;
}


auto CFobLicGenerator::SetPrivateKey() -> std::tuple<bool, ErrorMessage>
{
    return std::make_tuple(false, "Not implemented");
}

auto CFobLicGenerator::GenerateRegCodeForName(const std::string name) -> std::tuple<bool, RegCode>
{
    return std::make_tuple(false, "Not implemented");
}
