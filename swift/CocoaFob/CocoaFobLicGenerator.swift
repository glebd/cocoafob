//
//  CocoaFobKeyGenerator.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

/**
Generates CocoaFob registration keys
*/
public struct CocoaFobLicGenerator {
  
  var privKey: SecKeyRef
  
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
      flags: SecKeyImportExportFlags.ImportOnlyOne,
      passphrase: password,
      alertTitle: Unmanaged.passUnretained(emptyString),
      alertPrompt: Unmanaged.passUnretained(emptyString),
      accessRef: nil,
      keyUsage: nil,
      keyAttributes: nil)
    var keyFormat = SecExternalFormat.FormatPEMSequence
    var keyType = SecExternalItemType.ItemTypePrivateKey
    if let keyData = privateKeyPEM.dataUsingEncoding(NSUTF8StringEncoding) {
      let keyBytes = unsafeBitCast(keyData.bytes, UnsafePointer<UInt8>.self)
      let keyDataCF = CFDataCreate(nil, keyBytes, keyData.length)!
      var importArray: CFArray? = nil
      let osStatus = withUnsafeMutablePointers(&keyFormat, &keyType) { (pKeyFormat, pKeyType) -> OSStatus in
        SecItemImport(keyDataCF, nil, pKeyFormat, pKeyType, SecItemImportExportFlags(rawValue: 0), &params, nil, &importArray)
      }
      if osStatus != errSecSuccess || importArray == nil {
        return nil
      }
      let items = importArray! as NSArray
      if items.count >= 1 {
        self.privKey = items[0] as! SecKeyRef
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
  public func generate(name: String) throws -> String {
    guard name != "" else { throw CocoaFobError.Error }
    if let nameData = getNameData(name), signer = getSigner(nameData), encoder = getEncoder(), group = connectTransforms(signer, encoder: encoder) {
      let regData = try cfTry(CocoaFobError.Error) { return SecTransformExecute(group, $0) }
      if let reg = NSString(data: regData as! NSData, encoding: NSUTF8StringEncoding) {
        return String(reg).cocoaFobToReadableKey()
      } else {
        throw CocoaFobError.Error
      }
    }
    throw CocoaFobError.Error
  }
  
  // MARK: - Utility functions

  private func connectTransforms(signer: SecTransform, encoder: SecTransform) -> SecGroupTransform? {
    if let groupTransform = getGroupTransform() {
      return SecTransformConnectTransforms(signer, kSecTransformOutputAttributeName, encoder, kSecTransformInputAttributeName, groupTransform, nil)
    }
    return nil
  }

  private func getGroupTransform() -> SecGroupTransform? {
    return SecTransformCreateGroupTransform()
  }
  
  func getNameData(name: String) -> NSData? {
    return name.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  func getSigner(nameData: NSData) -> SecTransform? {
    do {
      let signer = try cfTry(.Error) { return SecSignTransformCreate(self.privKey, $0) }
      try cfTry(.Error) { return SecTransformSetAttribute(signer, kSecTransformInputAttributeName, nameData, $0) }
      try cfTry(.Error) { return SecTransformSetAttribute(signer, kSecDigestTypeAttribute, kSecDigestSHA1, $0) }
      return signer
    } catch {
      return nil
    }
  }
  
  private func getEncoder() -> SecTransform? {
    do {
      let encoder = try cfTry(.Error) { return SecEncodeTransformCreate(kSecBase32Encoding, $0) }
      return encoder
    } catch {
      return nil
    }
  }
  
}
