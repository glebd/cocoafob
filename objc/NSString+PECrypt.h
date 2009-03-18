//
//  NSString+PECrypt.h
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//
//  Base64 functions based on Dave Dribin's code:
//  http://www.dribin.org/dave/blog/archives/2006/03/12/base64_cocoa/
//

#import <Foundation/Foundation.h>

@interface NSString (PXCrypt)
- (NSData *)sha1;
- (NSString *)base64DecodeWithBreaks:(BOOL)lineBreaks;
- (NSString *)base64Decode;
@end
