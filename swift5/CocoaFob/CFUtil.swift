//
//  CFUtil.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 12/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

func cfTry(_ err: CocoaFobError, cfBlock: (UnsafeMutablePointer<Unmanaged<CFError>?>) -> DarwinBoolean) throws {
  var cferr: Unmanaged<CFError>? = nil
  if !cfBlock(&cferr).boolValue {
    if let cferr = cferr?.takeRetainedValue() {
      throw cferr
    } else {
      throw err
    }
  }
}

func cfTry<T>(_ err: CocoaFobError, cfBlock: (UnsafeMutablePointer<Unmanaged<CFError>?>) -> T?) throws -> T {
  var cferr: Unmanaged<CFError>? = nil
  if let result = cfBlock(&cferr) {
    return result
  }
  if let cferr = cferr?.takeRetainedValue() {
    throw cferr
  } else {
    throw err
  }
}
