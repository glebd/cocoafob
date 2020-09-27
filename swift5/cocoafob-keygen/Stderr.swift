//
//  StderrOutputStream.swift
//  CocoaFob
//
//  Created by Gleb Dolgich on 16/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

// From http://ericasadun.com/2015/06/09/swift-2-0-how-to-print/
public struct Stderr: OutputStreamType {
  public mutating func write(string: String) {
    fputs(string, stderr)
  }
}
