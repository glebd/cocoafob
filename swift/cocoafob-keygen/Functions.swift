//
//  Functions.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 16/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

func verifyRegKey(pubKeyPath: String, userName: String, regKey: String) throws -> Bool {
  let pubKeyPEM = try NSString(contentsOfFile: pubKeyPath, encoding: NSUTF8StringEncoding) as String
  let verifier = try CocoaFobLicVerifier(publicKeyPEM: pubKeyPEM)
  return verifier.verify(regKey, forName: userName)
}

func generateRegKey(pvtKeyPath: String, userName: String) throws -> String {
  let pvtKeyPEM = try NSString(contentsOfFile: pvtKeyPath, encoding: NSUTF8StringEncoding) as String
  let generator = try CocoaFobLicGenerator(privateKeyPEM: pvtKeyPEM)
  return try generator.generate(userName)
}

func generateRegURL(pvtKeyPath: String, userName: String, schema: String) throws -> String? {
  let regKey = try generateRegKey(pvtKeyPath, userName: userName)
  if let userNameData = userName.dataUsingEncoding(NSUTF8StringEncoding) {
    let userNameBase64 = userNameData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    return "\(schema)://\(userNameBase64)/\(regKey)"
  }
  return nil
}
