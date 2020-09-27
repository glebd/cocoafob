//
//  CocoaFobLicGenerator.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

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
    guard let keyData = privateKeyPEM.data(using: String.Encoding.utf8) else { return nil }
    let keyBytes = [UInt8](keyData)
    let keyDataCF = CFDataCreate(nil, keyBytes, keyData.count)!
    var importArray: CFArray? = nil
    let osStatus = withUnsafeMutablePointer(to: &keyFormat, {pKeyFormat -> OSStatus in
      withUnsafeMutablePointer(to: &keyType, { pKeyType in
        SecItemImport(keyDataCF, nil, pKeyFormat, pKeyType, SecItemImportExportFlags(rawValue: 0), &params, nil, &importArray)
      })
    })
    guard osStatus == errSecSuccess, importArray != nil else { return nil }
    let items = importArray! as NSArray
    guard items.count > 0 else { return nil }
    self.privKey = items[0] as! SecKey
  }
  
  // MARK: - Key generation
  
  /**
  Generates registration key for a user name
  
  - parameter userName: User name for which to generate a registration key
  - returns: Registration key
  */
  public func generate(_ name: String) throws -> String {
    guard name != "" else { throw CocoaFobError.error }
    guard let nameData = getNameData(name) else { throw CocoaFobError.error }
    guard let signer = getSigner(nameData) else { throw CocoaFobError.error }
    guard let encoder = getEncoder() else { throw CocoaFobError.error }
    guard let group = connectTransforms(signer, encoder: encoder) else { throw CocoaFobError.error }
    let regDataCF = try cfTry(CocoaFobError.error) { return SecTransformExecute(group, $0) }
    guard let regData = regDataCF as? Data else { throw CocoaFobError.error }
    guard let reg = String(data: regData, encoding: .utf8) else { throw CocoaFobError.error }
    return reg.cocoaFobToReadableKey()
  }
  
  // MARK: - Utility functions

  fileprivate func connectTransforms(_ signer: SecTransform, encoder: SecTransform) -> SecGroupTransform? {
    guard let groupTransform = getGroupTransform() else { return nil }
    return SecTransformConnectTransforms(signer, kSecTransformOutputAttributeName, encoder, kSecTransformInputAttributeName, groupTransform, nil)
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
