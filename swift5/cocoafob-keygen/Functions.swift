//
//  Functions.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 16/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

func verifyRegKey(pubKeyPath: String, userName: String, regKey: String) throws -> Bool {
    let pubKeyPEM = try String(contentsOfFile: pubKeyPath, encoding: .utf8)
    if let verifier = LicenseVerifier(publicKeyPEM: pubKeyPEM) {
        return verifier.verify(regKey, forName: userName)
    }
    return false
}

func generateRegKey(pvtKeyPath: String, userName: String) throws -> String {
    let pvtKeyPEM = try String(contentsOfFile: pvtKeyPath, encoding: .utf8)
    if let generator = LicenseGenerator(privateKeyPEM: pvtKeyPEM) {
        return try generator.generate(userName)
    }
    throw CocoaFobError.error
}

func generateRegURL(pvtKeyPath: String, userName: String, schema: String) throws -> String? {
    let regKey = try generateRegKey(pvtKeyPath: pvtKeyPath, userName: userName)
    if let userNameData = userName.data(using: .utf8) {
        let userNameBase64 = userNameData.base64EncodedData(options: .init(rawValue: 0))
        return "\(schema)://\(userNameBase64)/\(regKey)"
    }
    return nil
}
