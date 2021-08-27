//
//  CFobLicGenerator_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-17.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>
#include "CFob_ctest_common.hpp"
#include "CFobLicGenerator.hpp"

SCENARIO("When given a bad private key", "[base] [generator]")
{
    const auto privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n";
    auto licenseGen = CreateCFobLicGenerator< std::unique_ptr<CFobLicGenerator> >(privateKeyPEM);
    THEN("Factory function should return a nullptr")
    {
        REQUIRE(licenseGen == nullptr);
    }
}

SCENARIO("With valid data, generator should create registration code", "[base] [generator]")
{
    WHEN("Generator has a valid private key")
    {
        const auto privateKeyPEM = GetPrivateKey();
        auto licenseGen = CreateCFobLicGenerator<std::unique_ptr<CFobLicGenerator>>(privateKeyPEM);

        THEN("Generator should not be a nullptr")
        {
            REQUIRE(licenseGen != nullptr);
        }
        AND_THEN("Generator should produce a valid registration code")
        {
            auto name = "Joe Bloggs";
            //auto nameData = licenseGen->GetNameData(name);

            auto values = licenseGen->GenerateRegCodeForName(name);
            auto sucess = std::get<0>(values);
            auto registrationCode = std::get<1>(values);

            REQUIRE(sucess);
            REQUIRE(registrationCode.length() > 0);
        }
    }
}
