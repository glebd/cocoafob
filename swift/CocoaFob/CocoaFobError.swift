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
- InvalidKey(OSStatus): The supplied key is invalid; use `security error <OSStatus>` to get the message
- DecodeError: The supplied key could not be decoded
- InvalidName: Invalid user name supplied
- ErrorCreatingSignerTransform: Unable to create cryptographic signing transform
- ErrorConfiguringSignerTransform: Unable to configure signer transform
- ErrorCreatingEncoderTransform: Unable to create Base32 encoder transform
- ErrorCreatingDecoderTransform: Unable to create Base32 decoder transform
- ErrorConfiguringDecoderTransform: Unable to configure Base32 decoder transform
- ErrorCreatingGroupTransform: Unable to create group transform
- ErrorGeneratingRegKey: Unable to generate registration key
- ErrorCreatingVerifierTransform: Unable to create verifier transform
- ErrorConfiguringVerifierTransform: Unable to configure verifier transform
- VerificationError: Error verifying registration key
*/
enum CocoaFobError: ErrorType {
  case InvalidKey(OSStatus)
  case DecodeError
  case InvalidInput
  case ErrorCreatingSignerTransform
  case ErrorConfiguringSignerTransform
  case ErrorCreatingEncoderTransform
  case ErrorCreatingDecoderTransform
  case ErrorConfiguringDecoderTransform
  case ErrorCreatingGroupTransform
  case ErrorGeneratingRegKey
  case ErrorCreatingVerifierTransform
  case ErrorConfiguringVerifierTransform
  case VerificationError
}
