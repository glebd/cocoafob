//
//  CFobCrypto_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-08-25.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "catch.hpp"
#include "CFobCrypto.hpp"


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