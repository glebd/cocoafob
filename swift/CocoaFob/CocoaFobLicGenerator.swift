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
struct CocoaFobLicGenerator {
  
  var privKey: SecKeyRef
  
  /**
  Initializes key generator with a private key in PEM format
  
  - parameter privateKeyPEM: String containing PEM representation of the private key
  */
  init(privateKeyPEM: String) throws {
    var params = SecItemImportExportKeyParameters()
    var keyFormat = SecExternalFormat(kSecFormatPEMSequence)
    var keyType = SecExternalItemType(kSecItemTypePrivateKey)
    if let privateKeyData = privateKeyPEM.dataUsingEncoding(NSUTF8StringEncoding) {
      var importArray: Unmanaged<CFArray>? = nil
      let osStatus = withUnsafeMutablePointer(&importArray, { importArrayPtr in
         SecItemImport(privateKeyData, nil, &keyFormat, &keyType, 0, &params, nil, importArrayPtr)
      })
      if osStatus != errSecSuccess {
        throw CocoaFobError.InvalidPrivateKey(osStatus)
      }
      let items = importArray!.takeRetainedValue() as NSArray
      if items.count < 1 {
        throw CocoaFobError.InvalidPrivateKey(0)
      }
      self.privKey = items[0] as! SecKeyRef
    } else {
      throw CocoaFobError.InvalidPrivateKey(0)
    }
  }
}
