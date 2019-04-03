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
    let keygen = LicenseGenerator(privateKeyPEM: privateKeyPEM)
    XCTAssertNotNil(keygen?.privKey)
  }
  
  func testInitGeneratorFail() {
    let privateKeyPEM = "-----BEGIN DSA PRIVATE KEY-----\n"
    let keygen = LicenseGenerator(privateKeyPEM: privateKeyPEM)
    XCTAssert(keygen == nil)
  }
  
  func testGetNameData() {
    let keygen = LicenseGenerator(privateKeyPEM: privateKeyPEM)
    XCTAssertNotNil(keygen?.privKey)
    let name = "Joe Bloggs"
    let nameData = keygen?.getNameData(name)
    XCTAssertNotNil(nameData)
    if let nameData_ = nameData {
      let nameFromDataAsNSString = NSString(data: nameData_, encoding: String.Encoding.utf8.rawValue)
      XCTAssertNotNil(nameFromDataAsNSString)
      let nameFromData = String(nameFromDataAsNSString!)
      XCTAssertEqual(nameFromData, name)
    }
  }
  
  func testGetSignerPass() {
    let keygen = LicenseGenerator(privateKeyPEM: privateKeyPEM)
    XCTAssertNotNil(keygen?.privKey)
    let name = "Joe Bloggs"
    let nameData = keygen?.getNameData(name)
    XCTAssertNotNil(nameData)
    let signer = keygen?.getSigner(nameData!)
    XCTAssertNotNil(signer)
    
    // check name attribute
    if let signer_ = signer {
      let nameDataAttr = SecTransformGetAttribute(signer_, kSecTransformInputAttributeName)
      XCTAssertNotNil(nameDataAttr)
      let nameDataFromAttr = nameDataAttr! as! Data
      XCTAssertNotNil(nameDataFromAttr, "Expected to get name data back")
      let nameFromAttrAsNSString = NSString(data: nameDataFromAttr, encoding: String.Encoding.utf8.rawValue)
      XCTAssertNotNil(nameFromAttrAsNSString)
      let nameFromAttr = String(nameFromAttrAsNSString!)
      XCTAssertEqual(nameFromAttr, name)
      
      // check digest type attribute
      let digestTypeAttr = SecTransformGetAttribute(signer!, kSecDigestTypeAttribute)
      XCTAssertNotNil(digestTypeAttr)
      let digestTypeFromAttr = digestTypeAttr! as! NSString
      XCTAssertNotNil(digestTypeFromAttr, "Expected to get SHA1 transform type back")
      XCTAssertEqual(digestTypeFromAttr, kSecDigestSHA1 as NSString)
    }
  }
  
  func testToReadableKeyPass() {
    let unreadable = "GAWAEFCDW3KH4IP5E2DHKUHPQPN5P52V43SVGDYCCRS64XXNRYBBCT44EOGM3SKYV4272LQ6LQ======"
    let expected = "GAWAE-FCDW3-KH49P-5E2DH-KUHPQ-PN5P5-2V43S-VGDYC-CRS64-XXNRY-BBCT4-4E8GM-3SKYV-4272L-Q6LQ"
    let actual = unreadable.cocoaFobToReadableKey()
    XCTAssertEqual(actual, expected)
  }
  
  func testFromReadableKeyPass() {
    let readable = "GAWAE-FCDW3-KH49P-5E2DH-KUHPQ-PN5P5-2V43S-VGDYC-CRS64-XXNRY-BBCT4-4E8GM-3SKYV-4272L-Q6LQ"
    let expected = "GAWAEFCDW3KH4IP5E2DHKUHPQPN5P52V43SVGDYCCRS64XXNRYBBCT44EOGM3SKYV4272LQ6LQ"
    let actual = readable.cocoaFobFromReadableKey()
    XCTAssertEqual(actual, expected)
  }
  
  func testGeneratePass() {
    let keygen = LicenseGenerator(privateKeyPEM: privateKeyPEM)
    XCTAssertNotNil(keygen?.privKey)
    do {
      if let actual = try keygen?.generate("Joe Bloggs") {
        print(actual)
        XCTAssert(actual != "")
      }
    } catch {
      XCTAssert(false, "\(error)")
    }
  }
  
  func testInitVerifierPass() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
  }
  
  func testInitVerifierFail() {
    let publicKeyPEM = "-----BEGIN PUBLIC KEY-----\n"
    let keychecker = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNil(keychecker?.pubKey)
  }
  
  func testVerifyPass() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
    let name = "Joe Bloggs"
    let regKey = "GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q"
    let result = verifier?.verify(regKey, forName: name) ?? false
    XCTAssertTrue(result)
  }
  
  func testVerifyBadNameFail() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
    let name = "Joe Bloggs II"
    let regKey = "GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q"
    let result = verifier?.verify(regKey, forName: name) ?? false
    XCTAssertFalse(result)
  }
  
  func testVerifyBadKeyFail() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
    let name = "Joe Bloggs"
    let regKey = "foo bar"
    let result = verifier?.verify(regKey, forName: name) ?? false
    XCTAssertFalse(result)
  }
  
  func testVerifyEmptyKeyFail() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
    let name = "Joe Bloggs"
    let regKey = ""
    let result = verifier?.verify(regKey, forName: name) ?? false
    XCTAssertFalse(result)
  }
  
  func testVerifyEmptyNameAndKeyFail() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
    let name = ""
    let regKey = ""
    let result = verifier?.verify(regKey, forName: name) ?? false
    XCTAssertFalse(result)
  }
  
  func testVerifyEmptyNameFail() {
    let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
    XCTAssertNotNil(verifier?.pubKey)
    let name = ""
    let regKey = "GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q"
    let result = verifier?.verify(regKey, forName: name) ?? false
    XCTAssertFalse(result)
  }
  
  func testGenerateAndVerifyPass() {
    let keygen = LicenseGenerator(privateKeyPEM: privateKeyPEM)
    XCTAssertTrue(keygen != nil)
    XCTAssertNotNil(keygen?.privKey)
    let name = "Joe Bloggs"
    do {
      if let regKey = try keygen?.generate(name) {
        let verifier = LicenseVerifier(publicKeyPEM: publicKeyPEM)
        XCTAssertNotNil(verifier?.pubKey)
        let result = verifier?.verify(regKey, forName: name) ?? false
        XCTAssertTrue(result)
      }
    } catch {
      XCTAssert(false, "\(error)")
    }
  }
  
}
