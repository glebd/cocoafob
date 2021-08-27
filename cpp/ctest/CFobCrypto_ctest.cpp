//
//  CFobCrypto_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include <catch2/catch.hpp>
#include "CocoaFob/CFobCrypto.hpp"


SCENARIO("CreateDSAPubKeyFromPublicKeyPEM", "[]")
{
    GIVEN("An empty public string")
    {
        auto tupleResult =
        CFob::CreateDSAPubKeyFromPublicKeyPEM("");
        THEN("The result should be false")
        {
            auto result = std::get<0>(tupleResult);
            CHECK_FALSE(result);
        }
    }
}

SCENARIO("Public key exercise", "")
{
    WHEN("An empty string is passed")
    {
        auto result = CFob::IsPublicKeyComplete("");
        THEN("result should be false")
        {
            CHECK_FALSE(result);
        }
    }
    AND_WHEN("A garbage string is passed")
    {
        auto result = CFob::IsPublicKeyComplete("Holy cow");
        THEN("result should be false")
        {
            CHECK_FALSE(result);
        }
    }
}
