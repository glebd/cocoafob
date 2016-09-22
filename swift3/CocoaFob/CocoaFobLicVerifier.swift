//
//  CocoaFobLicVerifier.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 12/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

@available(*, deprecated: 1.0, renamed: "LicenseVerifier")
typealias CocoaFobLicVerifier = LicenseVerifier

/**
Verifies CocoaFob registration keys
*/
public struct LicenseVerifier {
  
  var pubKey: SecKey
  
  // MARK: - Initialization
  
  /**
  Initializes key verifier with a public key in PEM format
  
  - parameter publicKeyPEM: String containing PEM representation of the public key
  */
  public init?(publicKeyPEM: String) {
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
    var keyType = SecExternalItemType.itemTypePublicKey
    if let keyData = publicKeyPEM.data(using: String.Encoding.utf8) {
      let keyBytes = unsafeBitCast((keyData as NSData).bytes, to: UnsafePointer<UInt8>.self)
      let keyDataCF = CFDataCreate(nil, keyBytes, keyData.count)!
      var importArray: CFArray? = nil
      let osStatus = withUnsafeMutablePointer(to: &keyFormat) {pKeyFormat in
        withUnsafeMutablePointer(to: &keyType, {pKeyType in
          SecItemImport(keyDataCF, nil, pKeyFormat, pKeyType, SecItemImportExportFlags(rawValue: 0), &params, nil, &importArray)
        })
      }
      if osStatus != errSecSuccess || importArray == nil {
        return nil
      }
      let items = importArray! as NSArray
      if items.count >= 1 {
        self.pubKey = items[0] as! SecKey
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  /**
  Verifies registration key against registered name. Doesn't throw since you are most likely not interested in the reason registration verification failed.
  
  - parameter regKey: Registration key string
  - parameter name: Registered name string
  - returns: `true` if the registration key is valid for the given name, `false` if not
  */
  public func verify(_ regKey: String, forName name: String) -> Bool {
    do {
      if let keyData = regKey.cocoaFobFromReadableKey().data(using: String.Encoding.utf8), let nameData = name.data(using: String.Encoding.utf8) {
        let decoder = try getDecoder(keyData)
        let signature = try cfTry(.error) { SecTransformExecute(decoder, $0) }
        let verifier = try getVerifier(self.pubKey, signature: signature as! Data, nameData: nameData)
        let result = try cfTry(.error) { SecTransformExecute(verifier, $0) }
        let boolResult = result as! CFBoolean
        return Bool(boolResult)
      } else {
        return false
      }
    } catch {
      return false
    }
  }
  
  // MARK: - Helper functions
  
  fileprivate func getDecoder(_ keyData: Data) throws -> SecTransform {
    let decoder = try cfTry(.error) { return SecDecodeTransformCreate(kSecBase32Encoding, $0) }
    let _ = try cfTry(.error) { return SecTransformSetAttribute(decoder, kSecTransformInputAttributeName, keyData as CFTypeRef, $0) }
    return decoder
  }
  
  fileprivate func getVerifier(_ publicKey: SecKey, signature: Data, nameData: Data) throws -> SecTransform {
    let verifier = try cfTry(.error) { return SecVerifyTransformCreate(publicKey, signature as CFData?, $0) }
    let _ = try cfTry(.error) { return SecTransformSetAttribute(verifier, kSecTransformInputAttributeName, nameData as CFTypeRef, $0) }
    let _ = try cfTry(.error) { return SecTransformSetAttribute(verifier, kSecDigestTypeAttribute, kSecDigestSHA1, $0) }
    return verifier
  }
  
}
