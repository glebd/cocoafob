//
//  NSString+PECrypt.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License <http://creativecommons.org/licenses/by/3.0/>
//

#import "NSString+PECrypt.h"
#import <openssl/sha.h>

@implementation NSString (PXCrypt)

- (NSData *)sha1 {
	const int DIGEST_LEN = 20;
	unsigned char *buf = malloc(DIGEST_LEN);
	const char *str = [self UTF8String];
	size_t len = strlen(str);
	unsigned char *p = SHA1((unsigned char *)str, len, buf);
	if (!p) {
		free(buf);
		return nil;
	}
	NSData *digest = [NSData dataWithBytes:buf length:DIGEST_LEN];
	free(buf);
	return digest;
}

@end
