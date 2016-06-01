//
//  CFobLicVerifier_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-24.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#include "catch.hpp"

#include "CFobLicVerifier.hpp"

SCENARIO( "License generators should only be created if a public key is passed in", "[verifier]" )
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

SCENARIO( "License generators should handle bad data gracefully", "[verifier]" )
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