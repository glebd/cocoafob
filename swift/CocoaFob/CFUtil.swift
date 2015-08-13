//
//  CFUtil.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 12/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

func cfTry(err: CocoaFobError, cfBlock: UnsafeMutablePointer<Unmanaged<CFError>?> -> DarwinBoolean) throws {
  var cferr: Unmanaged<CFError>? = nil
  if !cfBlock(&cferr).boolValue {
    if let nserr = cferr?.takeRetainedValue() {
      throw nserr as NSError
    } else {
      throw err
    }
  }
}

func cfTry<T>(err: CocoaFobError, cfBlock: UnsafeMutablePointer<Unmanaged<CFError>?> -> T!) throws -> T {
  var cferr: Unmanaged<CFError>? = nil
  if let result = cfBlock(&cferr) {
    return result
  }
  if let nserr = cferr?.takeRetainedValue() {
    throw nserr as NSError
  } else {
    throw err
  }
}
