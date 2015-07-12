//
//  CocoaFobStringExt.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 12/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

extension String {
  
  /**
  Converts generated CocoaFob key to its human-readable form:
  - replaces Os with 8s and Is with 9s
  - trims padding characters at the end
  - inserts dashes every 5 characters
  
  - returns: Human-readable registration key
  */
  func cocoaFobToReadableKey() -> String {
    let replacedOwith8 = self.stringByReplacingOccurrencesOfString("O", withString: "8")
    let replacedIwith9 = replacedOwith8.stringByReplacingOccurrencesOfString("I", withString: "9")
    var key = replacedIwith9.stringByReplacingOccurrencesOfString("=", withString: "")
    
    var index = 5
    while index < key.utf8.count {
      key.splice(["-"], atIndex: advance(key.startIndex, index))
      index += 6
    }
    
    return key
  }
  
}
