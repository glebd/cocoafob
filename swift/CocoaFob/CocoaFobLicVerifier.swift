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
}
