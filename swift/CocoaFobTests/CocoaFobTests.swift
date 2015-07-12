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
  
  let publicKeyPEM = "-----BEGIN PUBLIC KEY-----\n"
  + "MIHxMIGoBgcqhkjOOAQBMIGcAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6o\n"
  + "yEv7Y2oT3itY5pbObgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10Ph\n"
  + "oV6zczFpi3C7FzWNAkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40\n"
  + "nkFNsK1OVwjo2ocn3MwW4Rdq6uLm3DlENRZ5bYrTA0QAAkEA4reDYZKAl1vx+8EI\n"
  + "MP/+2Z7ekydHfX0sTMDgkxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOr\n"
  + "y8MoDQ==\n"
  + "-----END PUBLIC KEY-----\n"
  
  func testInitGeneratorPass() {
    do {
      let keygen = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
      XCTAssertNotNil(keygen.privKey)
    } catch {
      XCTAssert(false, "Importing private key must succeed but produced \(error)")
    }
  }
  
  func testInitGeneratorFail() {
    let privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n"
    do {
      let _ = try CocoaFobLicGenerator(privateKeyPEM: privateKeyPEM)
    } catch let err as CocoaFobError {
      switch err {
      case CocoaFobError.InvalidKey(let osStatus):
        XCTAssert(osStatus == -25257, "Wrong OSStatus: \(osStatus)")
      default:
        XCTAssert(false, "Expected CocoaFobError.InvalidKey(-25257), got \(err)")
      }
    } catch {
      XCTAssert(false, "Expected CocoaFobError.InvalidKey(-25257), got \(error)")
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
  
  func testInitVerifierPass() {
    do {
      let keygen = try CocoaFobLicVerifier(publicKeyPEM: publicKeyPEM)
      XCTAssertNotNil(keygen.pubKey)
    } catch {
      XCTAssert(false, "Importing public key must succeed but produced \(error)")
    }
  }
  
  func testInitVerifierFail() {
    let publicKeyPEM = "-----BEGIN PUBLIC KEY-----\n"
    do {
      let _ = try CocoaFobLicVerifier(publicKeyPEM: publicKeyPEM)
    } catch let err as CocoaFobError {
      switch err {
      case CocoaFobError.InvalidKey(let osStatus):
        XCTAssert(osStatus == -25257, "Wrong OSStatus: \(osStatus)")
      default:
        XCTAssert(false, "Expected CocoaFobError.InvalidKey(-25257), got \(err)")
      }
    } catch {
      XCTAssert(false, "Expected CocoaFobError.InvalidKey(-25257), got \(error)")
    }
  }
  
}
