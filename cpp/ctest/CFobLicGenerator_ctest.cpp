//
//  CFobLicGenerator_ctest.cpp
//  cocoafob
//
//  Created by Jaime Rios on 2016-05-17.
//  Copyright © 2016 Jaime O. Rios. All rights reserved.
//

#define CATCH_CONFIG_MAIN
#include "catch.hpp"

#include <memory>
#include "CFobLicGenerator.hpp"

TEST_CASE("Construct class", "[base]")
{
    const auto privateKeyPEM = R"PEM(
                                -----BEGIN DSA PRIVATE KEY-----\n
                                MIH5AgEAAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6oyEv7Y2oT3itY5pbO\n
                                bgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10PhoV6zczFpi3C7FzWN\n
                                AkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40nkFNsK1OVwjo2ocn\n
                                3MwW4Rdq6uLm3DlENRZ5bYrTAkEA4reDYZKAl1vx+8EIMP/+2Z7ekydHfX0sTMDg\n
                                kxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOry8MoDQIVAIXgAB9GBLh4\n
                                keUwLHBtpClnD5E8\n
                                -----END DSA PRIVATE KEY-----\n
                                )PEM";
    
    auto licenseGen = std::make_unique<CFobLicGenerator>(privateKeyPEM);
    REQUIRE(licenseGen != nullptr);
    
    auto name = "Joe Bloggs";
    //auto nameData = licenseGen->GetNameData(name);
    
    auto regCodeVals = licenseGen->GenerateRegCodeForName(name);
    auto regCodeResult = std::get<0>(regCodeVals);
    
    REQUIRE(regCodeResult);
}

TEST_CASE("Construct class bad", "[base]")
{
    const auto privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n";
    
    auto licenseGen = std::make_unique<CFobLicGenerator>(privateKeyPEM);
    REQUIRE(licenseGen == nullptr);
}