//
//  CocoaFobError.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 05/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

/**
Custom error type:
- InvalidPrivateKey(OSStatus): The supplied private key is invalid
- DecodeError: The supplied key could not be decoded
- SigningFailed: The cryptographic signing operation resulted in an error
*/
enum CocoaFobError: ErrorType {
  case InvalidPrivateKey(OSStatus)
  case DecodeError
  case SigningFailed
}
