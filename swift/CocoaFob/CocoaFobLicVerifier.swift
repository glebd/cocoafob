//
//  CocoaFobLicVerifier.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 12/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

/**
Verifies CocoaFob registration keys
*/
public struct CocoaFobLicVerifier {
  
  var pubKey: SecKeyRef
  
  // MARK: - Initialization
  
  /**
  Initializes key verifier with a public key in PEM format
  
  - parameter publicKeyPEM: String containing PEM representation of the public key
  */
  public init(publicKeyPEM: String) throws {
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
    var keyType = SecExternalItemType.ItemTypePublicKey
    if let keyData = publicKeyPEM.dataUsingEncoding(NSUTF8StringEncoding) {
      var importArray: CFArray? = nil
      let osStatus = withUnsafeMutablePointer(importArray) { importArrayPtr in
        SecItemImport(keyData, nil, &keyFormat, &keyType, 0, &params, nil, importArrayPtr)
      }
      if osStatus != errSecSuccess {
        throw CocoaFobError.InvalidKey(osStatus)
      }
      if let items = importArray as? NSArray where items.count >= 1 {
        self.pubKey = items[0] as! SecKeyRef
      } else {
        throw CocoaFobError.InvalidKey(0)
      }
    } else {
      throw CocoaFobError.InvalidKey(0)
    }
  }
  
  /**
  Verifies registration key against registered name. Doesn't throw since you are mst likely not interested in the reason registration verification failed.
  
  - parameter regKey: Registration key string
  - parameter name: Registered name string
  - returns: `true` if the registration key is valid for the given name, `false` if not
  */
  public func verify(regKey: String, forName name: String) -> Bool {
    do {
      if let keyData = regKey.cocoaFobFromReadableKey().dataUsingEncoding(NSUTF8StringEncoding), nameData = name.dataUsingEncoding(NSUTF8StringEncoding) {
        let decoder = try getDecoder(keyData)
        let signature = try cfTry(.DecodeError) { SecTransformExecute(decoder, $0) }
        let verifier = try getVerifier(self.pubKey, signature: signature as! NSData, nameData: nameData)
        let result = try cfTry(.VerificationError) { SecTransformExecute(verifier, $0) }
        let boolResult = result as! CFBooleanRef
        return Bool(boolResult)
      } else {
        return false
      }
    } catch {
      return false
    }
  }
  
  // MARK: - Helper functions
  
  private func getDecoder(keyData: NSData) throws -> SecTransform {
    let decoder = try cfTry(.ErrorCreatingDecoderTransform) { return SecDecodeTransformCreate(kSecBase32Encoding, $0) }
    try cfTry(.ErrorConfiguringDecoderTransform) { return SecTransformSetAttribute(decoder, kSecTransformInputAttributeName, keyData, $0) }
    return decoder
  }
  
  private func getVerifier(publicKey: SecKeyRef, signature: NSData, nameData: NSData) throws -> SecTransform {
    let verifier = try cfTry(.ErrorCreatingVerifierTransform) { return SecVerifyTransformCreate(publicKey, signature, $0) }
    try cfTry(.ErrorConfiguringVerifierTransform) { return SecTransformSetAttribute(verifier, kSecTransformInputAttributeName, nameData, $0) }
    try cfTry(.ErrorConfiguringVerifierTransform) { return SecTransformSetAttribute(verifier, kSecDigestTypeAttribute, kSecDigestSHA1, $0) }
    return verifier
  }
  
}
