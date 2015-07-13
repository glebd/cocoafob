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
    var params = SecItemImportExportKeyParameters()
    var keyFormat = SecExternalFormat(kSecFormatPEMSequence)
    var keyType = SecExternalItemType(kSecItemTypePublicKey)
    if let keyData = publicKeyPEM.dataUsingEncoding(NSUTF8StringEncoding) {
      var importArray: Unmanaged<CFArray>? = nil
      let osStatus = withUnsafeMutablePointer(&importArray) { importArrayPtr in
        SecItemImport(keyData, nil, &keyFormat, &keyType, 0, &params, nil, importArrayPtr)
      }
      if osStatus != errSecSuccess {
        throw CocoaFobError.InvalidKey(osStatus)
      }
      let items = importArray!.takeRetainedValue() as NSArray
      if items.count < 1 {
        throw CocoaFobError.InvalidKey(0)
      }
      self.pubKey = items[0] as! SecKeyRef
    } else {
      throw CocoaFobError.InvalidKey(0)
    }
  }
  
  /**
  Verifies registration key against registered name
  
  - parameter regKey: Registration key string
  - parameter name: Registered name string
  - returns: `true` if the registration key is valid for the given name, `false` if not
  */
  public func verify(regKey: String, forName name: String) -> Bool {
    do {
      if let keyData = regKey.cocoaFobFromReadableKey().dataUsingEncoding(NSUTF8StringEncoding), nameData = name.dataUsingEncoding(NSUTF8StringEncoding) {
        let decoder = try getDecoder(keyData)
        let signature = try cfTry(.DecodeError) { SecTransformExecute(decoder.takeUnretainedValue(), $0) }
        let verifier = try getVerifier(self.pubKey, signature: signature as! NSData, nameData: nameData)
        let result = try cfTry(.VerificationError) { SecTransformExecute(verifier.takeUnretainedValue(), $0) }
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
  
  private func getDecoder(keyData: NSData) throws -> Unmanaged<SecTransform> {
    let decoder = try cfTry(.ErrorCreatingDecoderTransform) { return SecDecodeTransformCreate(kSecBase32Encoding, $0) }
    try cfTry(.ErrorConfiguringDecoderTransform) { return SecTransformSetAttribute(decoder.takeUnretainedValue(), kSecTransformInputAttributeName, keyData, $0) }
    return decoder
  }
  
  private func getVerifier(publicKey: SecKeyRef, signature: NSData, nameData: NSData) throws -> Unmanaged<SecTransform> {
    let verifier = try cfTry(.ErrorCreatingVerifierTransform) { return SecVerifyTransformCreate(publicKey, signature, $0) }
    try cfTry(.ErrorConfiguringVerifierTransform) { return SecTransformSetAttribute(verifier.takeUnretainedValue(), kSecTransformInputAttributeName, nameData, $0) }
    try cfTry(.ErrorConfiguringVerifierTransform) { return SecTransformSetAttribute(verifier.takeUnretainedValue(), kSecDigestTypeAttribute, kSecDigestSHA1, $0) }
    return verifier
  }
  
}
