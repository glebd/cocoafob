//
//  CocoaFobTests.swift
//  CocoaFobTests
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import XCTest
@testable import CocoaFob

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
  
  func testGetNameData() {
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
      let name = "Joe Bloggs"
      let nameData = try keygen.getNameData(name)
      let nameFromDataAsNSString = NSString(data: nameData, encoding: NSUTF8StringEncoding)
      XCTAssertNotNil(nameFromDataAsNSString)
      let nameFromData = String(nameFromDataAsNSString!)
      XCTAssertEqual(nameFromData, name)
    } catch {
      XCTAssert(false, "\(error)")
    }
  }
  
  func testGetSignerPass() {
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
      let name = "Joe Bloggs"
      let nameData = try keygen.getNameData(name)
      let signer = try keygen.getSigner(nameData)
      
      // check name attribute
      let nameDataAttr = SecTransformGetAttribute(signer.takeUnretainedValue(), kSecTransformInputAttributeName)
      let nameDataFromAttr = nameDataAttr.takeUnretainedValue() as! NSData
      XCTAssertNotNil(nameDataFromAttr, "Expected to get name data back")
      let nameFromAttrAsNSString = NSString(data: nameDataFromAttr, encoding: NSUTF8StringEncoding)
      XCTAssertNotNil(nameFromAttrAsNSString)
      let nameFromAttr = String(nameFromAttrAsNSString!)
      XCTAssertEqual(nameFromAttr, name)
      
      // check digest type attribute
      let digestTypeAttr = SecTransformGetAttribute(signer.takeUnretainedValue(), kSecDigestTypeAttribute)
      let digestTypeFromAttr = digestTypeAttr.takeUnretainedValue() as! NSString
      XCTAssertNotNil(digestTypeFromAttr, "Expected to get SHA1 transform type back")
      XCTAssertEqual(digestTypeFromAttr, kSecDigestSHA1)
    } catch {
      XCTAssert(false, "\(error)")
    }
  }
  
  func testGeneratePass() {
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
      let actual = try keygen.generate("Joe Bloggs")
      XCTAssert(actual != "")
    } catch {
      XCTAssert(false, "\(error)")
    }
  }
  
}
