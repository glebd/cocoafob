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
- InvalidPrivateKey(OSStatus): The supplied private key is invalid; use `security error <OSStatus>` to get the message
- DecodeError: The supplied key could not be decoded
- InvalidName: Invalid user name supplied
- ErrorCreatingSignerTransform: Unable to create cryptographic signing transform
- ErrorConfiguringSignerTransform: Unable to configure signer transform
- ErrorCreatingEncoderTransform: Unable to create Base32 encoder transform
- ErrorCreatingGroupTransform: Unable to create group transform
- ErrorGeneratingRegKey: Unable to generate registration key
*/
enum CocoaFobError: ErrorType {
  case InvalidPrivateKey(OSStatus)
  case DecodeError
  case InvalidName
  case ErrorCreatingSignerTransform
  case ErrorConfiguringSignerTransform
  case ErrorCreatingEncoderTransform
  case ErrorCreatingGroupTransform
  case ErrorGeneratingRegKey
}
