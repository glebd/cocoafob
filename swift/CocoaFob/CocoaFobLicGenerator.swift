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
  public init(privateKeyPEM: String) throws {
    var password = Unmanaged.passUnretained(NSString(string: "") as AnyObject)
    var emptyString = "" as NSString
    var params = SecItemImportExportKeyParameters(
      version: UInt32(bitPattern: SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION),
      flags: SecKeyImportExportFlags.ImportOnlyOne,
      passphrase: password,
      alertTitle: Unmanaged.passUnretained(NSString(string: "")),
      alertPrompt: Unmanaged.passUnretained(NSString(string: "")),
      accessRef: nil,
      keyUsage: nil,
      keyAttributes: nil)
    var keyFormat = SecExternalFormat.FormatPEMSequence
    var keyType = SecExternalItemType.ItemTypePrivateKey
    if let keyData = privateKeyPEM.dataUsingEncoding(NSUTF8StringEncoding) {
      var importArray: CFArray? = nil
      let osStatus = withUnsafeMutablePointer(&importArray) { importArrayPtr in
        SecItemImport(keyData, nil, &keyFormat, &keyType, 0, &params, nil, importArrayPtr)
      }
      if osStatus != errSecSuccess {
        throw CocoaFobError.InvalidKey(osStatus)
      }
      if let items = importArray as? NSArray where items.count >= 1 {
        self.privKey = items[0] as! SecKeyRef
      } else {
        throw CocoaFobError.InvalidKey(0)
      }
    } else {
      throw CocoaFobError.InvalidKey(0)
    }
  }
  
  // MARK: - Key generation
  
  /**
  Generates registration key for a user name
  
  - parameter userName: User name for which to generate a registration key
  - returns: Registration key
  */
  public func generate(name: String) throws -> String {
    guard name != "" else { throw CocoaFobError.InvalidInput }
    let nameData = try getNameData(name)
    let signer = try getSigner(nameData)
    let encoder = try getEncoder()
    if let group = try connectTransforms(signer, encoder: encoder) {
      let regData = try cfTry(CocoaFobError.ErrorGeneratingRegKey) { return SecTransformExecute(group, $0) }
      if let reg = NSString(data: regData as! NSData, encoding: NSUTF8StringEncoding) {
        return String(reg).cocoaFobToReadableKey()
      } else {
        throw CocoaFobError.ErrorGeneratingRegKey
      }
    }
  }
  
  // MARK: - Utility functions

  private func connectTransforms(signer: SecTransform, encoder: SecTransform) throws -> SecGroupTransform? {
    let groupTransform = try getGroupTransform()
    return SecTransformConnectTransforms(signer, kSecTransformOutputAttributeName, encoder, kSecTransformInputAttributeName, groupTransform, nil)
  }

  private func getGroupTransform() throws -> SecGroupTransform {
    return SecTransformCreateGroupTransform()
  }
  
  func getNameData(name: String) throws -> NSData {
    if let nameData = name.dataUsingEncoding(NSUTF8StringEncoding) {
      return nameData
    }
    throw CocoaFobError.InvalidInput
  }
  
  func getSigner(nameData: NSData) throws -> SecTransform {
    let signer = try cfTry(.ErrorCreatingSignerTransform) { return SecSignTransformCreate(self.privKey, $0) }
    try cfTry(.ErrorConfiguringSignerTransform) { return SecTransformSetAttribute(signer, kSecTransformInputAttributeName, nameData, $0) }
    try cfTry(.ErrorConfiguringSignerTransform) { return SecTransformSetAttribute(signer, kSecDigestTypeAttribute, kSecDigestSHA1, $0) }
    return signer
  }
  
  private func getEncoder() throws -> SecTransform {
    let encoder = try cfTry(.ErrorCreatingEncoderTransform) { return SecEncodeTransformCreate(kSecBase32Encoding, $0) }
    return encoder
  }
  
}
