//
//  CocoaFobLicGenerator.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

@available(*, deprecated: 1.0, renamed: "LicenseGenerator")
typealias CocoaFobLicGenerator = LicenseGenerator

/**
Generates CocoaFob registration keys
*/
public struct LicenseGenerator {
  
  var privKey: SecKey
  
  // MARK: - Initialization
  
  /**
  Initializes key generator with a private key in PEM format
  
  - parameter privateKeyPEM: String containing PEM representation of the private key
  */
  public init?(privateKeyPEM: String) {
    let emptyString = "" as NSString
    let password = Unmanaged.passUnretained(emptyString as AnyObject)
    var params = SecItemImportExportKeyParameters(
      version: UInt32(bitPattern: SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION),
      flags: SecKeyImportExportFlags.importOnlyOne,
      passphrase: password,
      alertTitle: Unmanaged.passUnretained(emptyString),
      alertPrompt: Unmanaged.passUnretained(emptyString),
      accessRef: nil,
      keyUsage: nil,
      keyAttributes: nil)
    var keyFormat = SecExternalFormat.formatPEMSequence
    var keyType = SecExternalItemType.itemTypePrivateKey
    if let keyData = privateKeyPEM.data(using: String.Encoding.utf8) {
      let keyBytes = unsafeBitCast((keyData as NSData).bytes, to: UnsafePointer<UInt8>.self)
      let keyDataCF = CFDataCreate(nil, keyBytes, keyData.count)!
      var importArray: CFArray? = nil
      let osStatus = withUnsafeMutablePointer(to: &keyFormat, {pKeyFormat -> OSStatus in
        withUnsafeMutablePointer(to: &keyType, {pKeyType in
          SecItemImport(keyDataCF, nil, pKeyFormat, pKeyType, SecItemImportExportFlags(rawValue: 0), &params, nil, &importArray)
        })
      })
      if osStatus != errSecSuccess || importArray == nil {
        return nil
      }
      let items = importArray! as NSArray
      if items.count >= 1 {
        self.privKey = items[0] as! SecKey
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  // MARK: - Key generation
  
  /**
  Generates registration key for a user name
  
  - parameter userName: User name for which to generate a registration key
  - returns: Registration key
  */
  public func generate(_ name: String) throws -> String {
    guard name != "" else { throw CocoaFobError.error }
    if let nameData = getNameData(name), let signer = getSigner(nameData), let encoder = getEncoder(), let group = connectTransforms(signer, encoder: encoder) {
      let regData = try cfTry(CocoaFobError.error) { return SecTransformExecute(group, $0) }
      if let reg = NSString(data: regData as! Data, encoding: String.Encoding.utf8.rawValue) {
        return String(reg).cocoaFobToReadableKey()
      } else {
        throw CocoaFobError.error
      }
    }
    throw CocoaFobError.error
  }
  
  // MARK: - Utility functions

  fileprivate func connectTransforms(_ signer: SecTransform, encoder: SecTransform) -> SecGroupTransform? {
    if let groupTransform = getGroupTransform() {
      return SecTransformConnectTransforms(signer, kSecTransformOutputAttributeName, encoder, kSecTransformInputAttributeName, groupTransform, nil)
    }
    return nil
  }

  fileprivate func getGroupTransform() -> SecGroupTransform? {
    return SecTransformCreateGroupTransform()
  }
  
  func getNameData(_ name: String) -> Data? {
    return name.data(using: String.Encoding.utf8)
  }
  
  func getSigner(_ nameData: Data) -> SecTransform? {
    do {
      let signer = try cfTry(.error) { return SecSignTransformCreate(self.privKey, $0) }
      let _ = try cfTry(.error) { return SecTransformSetAttribute(signer, kSecTransformInputAttributeName, nameData as CFTypeRef, $0) }
      let _ = try cfTry(.error) { return SecTransformSetAttribute(signer, kSecDigestTypeAttribute, kSecDigestSHA1, $0) }
      return signer
    } catch {
      return nil
    }
  }
  
  fileprivate func getEncoder() -> SecTransform? {
    do {
      let encoder = try cfTry(.error) { return SecEncodeTransformCreate(kSecBase32Encoding, $0) }
      return encoder
    } catch {
      return nil
    }
  }
  
}
