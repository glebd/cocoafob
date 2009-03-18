//
//  NSData+PECrypt.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import "NSData+PECrypt.h"
#import "encoder.h"


@implementation NSData (PECrypt)

- (NSString *)base32 {
	if (![self length])
		return @"";
	size_t bufsize = base32_encoder_buffer_size([self length]);
	char *buf = malloc(bufsize);
	if (!buf)
		return @"";
	base32_encode((uint8_t *)buf, bufsize, [self bytes], [self length]);
	NSString *s = [NSString stringWithCString:buf length:bufsize];
	free(buf);
	return s;
}

@end
