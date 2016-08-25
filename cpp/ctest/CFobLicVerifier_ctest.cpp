//
//  CFobLicVerifier_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "catch.hpp"
#include "CFobLicVerifier.hpp"


SCENARIO( "License generators should only be created if a public key is passed in", "[verifier] [publicKey]" )
{
    GIVEN("No public key")
    {
        auto licenseVer = CreateCFobLicVerifier("");
        
        THEN( "The result should be a nullptr" )
        {
            REQUIRE(licenseVer == nullptr);
        }
    }
}

SCENARIO( "License verifier should handle bad data gracefully", "[verifier]" )
{
    GIVEN("A constructed non-nullptr instance to license verifier")
    {
        auto publicKey = UTF8String{""};
        
        publicKey += "MIHxMIGoBgcqhkj";
        publicKey += "OOAQBMIGcAkEA8wm04e0QcQRoAVJW";
        publicKey += "WnUw/4rQEKbLKjujJu6o\n";
        publicKey += "yE";
        publicKey += "v7Y2oT3itY5pbObgYCHEu9FBizqq7apsWYSF3YX";
        publicKey += "iRjKlg10wIVALfs9eVL10Ph\n";
        publicKey += "oV6zczFpi3C7FzWNAkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw";
        publicKey += "/BCC13IAsW40\n";
        publicKey += "nkFNsK1OVwjo2ocn";
        publicKey += "3M";
        publicKey += "wW";
        publicKey += "4Rdq6uLm3DlENRZ5bYrTA";
        publicKey += "0QAAkEA4reDYZKAl1vx+8EI\n";
        publicKey += "MP/+";
        publicKey += "2Z7ekydHfX0sTMDgkxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOr\n";
        publicKey += "y8MoDQ==\n";
        
        auto licenseVer = CreateCFobLicVerifier(publicKey);
        REQUIRE(licenseVer != nullptr);
        
        WHEN( "Bad data is passed in" )
        {
            auto result = licenseVer->VerifyRegCodeForName("", "");
            
            THEN( "The result should point to an error of some sort" )
            {
                auto boolResult = std::get<0>(result);
                REQUIRE_FALSE(boolResult);
                
                auto errorMessage = std::get<1>(result);
                REQUIRE( errorMessage.length() != 0 );
            }
        }
    }
}

SCENARIO( "License verifier should handle good data", "[verifier]" )
{
    GIVEN("A constructed non-nullptr instance to license verifier")
    {
        auto publicKey = UTF8String{""};
        
        publicKey += "MIHxMIGoBgcqhkj";
        publicKey += "OOAQBMIGcAkEA8wm04e0QcQRoAVJW";
        publicKey += "WnUw/4rQEKbLKjujJu6o\n";
        publicKey += "yE";
        publicKey += "v7Y2oT3itY5pbObgYCHEu9FBizqq7apsWYSF3YX";
        publicKey += "iRjKlg10wIVALfs9eVL10Ph\n";
        publicKey += "oV6zczFpi3C7FzWNAkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw";
        publicKey += "/BCC13IAsW40\n";
        publicKey += "nkFNsK1OVwjo2ocn";
        publicKey += "3M";
        publicKey += "wW";
        publicKey += "4Rdq6uLm3DlENRZ5bYrTA";
        publicKey += "0QAAkEA4reDYZKAl1vx+8EI\n";
        publicKey += "MP/+";
        publicKey += "2Z7ekydHfX0sTMDgkxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOr\n";
        publicKey += "y8MoDQ==\n";
        
        auto licenseVer = CreateCFobLicVerifier(publicKey);
        REQUIRE(licenseVer != nullptr);
        
        WHEN( "Good data is passed in" )
        {
            const auto regCode = UTF8String{"GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q"};
            const auto name    = UTF8String{"Joe Bloggs"};
            
            auto result = licenseVer->VerifyRegCodeForName(regCode, name);
            
            THEN( "The result should not have any error" )
            {
                auto boolResult = std::get<0>(result);
                CHECK(boolResult);
                
                auto errorMessage = std::get<1>(result);
                CHECK( errorMessage.length() == 0 );
            }
        }
    }
}

SCENARIO("License verifier should work with complete PEM key", "[verifier] [publicKey]")
{
    GIVEN("A constructed non-nullptr instance to license verifier")
    {
        const auto publicKey = R"PEM(-----BEGIN PUBLIC KEY-----
        MIHxMIGoBgcqhkjOOAQBMIGcAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6o
        yEv7Y2oT3itY5pbObgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10Ph
        oV6zczFpi3C7FzWNAkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40
        nkFNsK1OVwjo2ocn3MwW4Rdq6uLm3DlENRZ5bYrTA0QAAkEA4reDYZKAl1vx+8EI
        MP/+2Z7ekydHfX0sTMDgkxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOr
        y8MoDQ==
        -----END PUBLIC KEY-----
        )PEM";
        
        auto licenseVer = CreateCFobLicVerifier(publicKey);
        REQUIRE(licenseVer != nullptr);
        
        WHEN( "Good data is passed in" )
        {
            const auto regCode = UTF8String{"GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-"\
                "VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q"};
            const auto name    = UTF8String{"Joe Bloggs"};
            
            auto result = licenseVer->VerifyRegCodeForName(regCode, name);
            
            THEN( "The result should not have any error" )
            {
                auto boolResult = std::get<0>(result);
                CHECK(boolResult);
                
                auto errorMessage = std::get<1>(result);
                CHECK( errorMessage.length() == 0 );
            }
        }

    }
}


