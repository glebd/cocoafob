//
//  CocoaFobTests.swift
//  CocoaFobTests
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import XCTest

class CocoaFobTests: XCTestCase {
  
  let privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n"
    + "MIH5AgEAAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6oyEv7Y2oT3itY5pbO\n"
    + "bgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10PhoV6zczFpi3C7FzWN\n"
    + "AkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40nkFNsK1OVwjo2ocn\n"
    + "3MwW4Rdq6uLm3DlENRZ5bYrTAkEA4reDYZKAl1vx+8EIMP/+2Z7ekydHfX0sTMDg\n"
    + "kxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOry8MoDQIVAIXgAB9GBLh4\n"
    + "keUwLHBtpClnD5E8\n"
    + "-----END DSA PRIVATE KEY-----\n"
  
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
  
  func testSetPrivateKeyPass() {
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
    } catch {
      XCTAssert(false, "Importing private key must succeed but produced \(error)")
    }
  }
  
  func testSetPrivateKeyFail() {
    let privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n"
    do {
      let _ = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
    } catch let err as CocoaFobError {
      switch err {
      case CocoaFobError.InvalidPrivateKey(let osStatus):
        XCTAssert(osStatus == -25257, "Wrong OSStatus: \(osStatus)")
      default:
        XCTAssert(false, "Expected CocoaFobError.InvalidPrivateKey(-25257), got \(err)")
      }
    } catch {
      XCTAssert(false, "Expected CocoaFobError.InvalidPrivateKey(-25257), got \(error)")
    }
  }
  
  func testGeneratePass() {
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
      let actual = try keygen.generate("Joe Bloggs")
      let expected = "GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q"
      XCTAssert(actual == expected, "Expected: \(expected), actual: \(actual)")
    } catch {
      XCTAssert(false, "\(error)")
    }
  }
  
}
