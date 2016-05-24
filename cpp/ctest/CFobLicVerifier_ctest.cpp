//
//  CFobLicVerifier_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "catch.hpp"

#include "CFobLicVerifier.hpp"

TEST_CASE("Construct class", "[base] [verifier]")
{
    auto licenseVer = CreateCFobLicVerifier("");
    REQUIRE(licenseVer != nullptr);
    
    auto result = licenseVer->VerifyRegCodeForName("", "");
}