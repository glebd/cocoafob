//
//  CocoaFobTests.swift
//  CocoaFobTests
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import XCTest

class CocoaFobTests: XCTestCase {
    
    /*override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }*/
    
    /*override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }*/
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }*/
  
  func testSetPrivateKey() {
    let privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n"
      + "MIH5AgEAAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6oyEv7Y2oT3itY5pbO\n"
      + "bgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10PhoV6zczFpi3C7FzWN\n"
      + "AkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40nkFNsK1OVwjo2ocn\n"
      + "3MwW4Rdq6uLm3DlENRZ5bYrTAkEA4reDYZKAl1vx+8EIMP/+2Z7ekydHfX0sTMDg\n"
      + "kxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOry8MoDQIVAIXgAB9GBLh4\n"
      + "keUwLHBtpClnD5E8\n"
      + "-----END DSA PRIVATE KEY-----\n"
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
    } catch {
      XCTAssert(false, "Importing private key must succeed but produced \(error)")
    }
  }
    
}
