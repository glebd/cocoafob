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
  return ""
}
