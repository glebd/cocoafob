//
//  NSString+PECrypt.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import "NSString+PECrypt.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (PXCrypt)

- (NSData *)sha1 {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA1([data bytes], (unsigned int)[data length], digest);
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

// Formely based on Dave Dribin's code, http://www.dribin.org/dave/blog/archives/2006/03/12/base64_cocoa/
// Updated to use CommonCrypto instead of OpenSSL
- (NSString *)base64DecodeWithBreaks:(BOOL)lineBreaks {
    SecTransformRef transform = SecDecodeTransformCreate(kSecBase64Encoding, NULL);
    NSData *output = nil;
    if (SecTransformSetAttribute(transform, kSecTransformInputAttributeName, [self dataUsingEncoding:NSASCIIStringEncoding], NULL)) {
        output = (NSData *)SecTransformExecute(transform, NULL);
    }
    CFRelease(transform);
    NSString *decoded = [NSString stringWithUTF8String:[output bytes]];
    [output release];
    return decoded;
}

- (NSString *)base64Decode {
	return [self base64DecodeWithBreaks:NO];
}


@end
