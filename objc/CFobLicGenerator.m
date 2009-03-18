//
//  CFobLicGenerator.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd.
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution Licence 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import "NSData+PECrypt.h"
#import "NSString+PECrypt.h"
#import "CFobLicGenerator.h"
#import <openssl/evp.h>
#import <openssl/err.h>
#import <openssl/pem.h>


@interface CFobLicGenerator ()
- (void)initOpenSSL;
- (void)shutdownOpenSSL;
@end


@implementation CFobLicGenerator

@synthesize regName;
@synthesize regCode;
@synthesize lastError;

#pragma mark -
#pragma mark Class methods

+ (id)generatorWithPrivateKey:(NSString *)privKey {
	return [[[CFobLicGenerator alloc] initWithPrivateKey:privKey] autorelease];
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
	return [self initWithPrivateKey:nil];
}

- (id)initWithPrivateKey:(NSString *)privKey {
	if (![super init])
		return nil;
	[self initOpenSSL];
	[self setPrivateKey:privKey];
	return self;
}

- (void)dealloc {
	if (dsa)
		DSA_free(dsa);
	self.regCode = nil;
	self.regName = nil;
	self.lastError = nil;
	[self shutdownOpenSSL];
	[super dealloc];
}

#pragma mark -
#pragma mark API

- (BOOL)setPrivateKey:(NSString *)privKey {
	// Validate the argument.
	if (!privKey || ![privKey length]) {
		self.lastError = @"Invalid key";
		return NO;
	}
	if (dsa)
		DSA_free(dsa);
	dsa = DSA_new();
	// Prepare BIO to read PEM-encoded private key from memory.
	// Prepare buffer given NSString.
	const char *privkeyCString = [privKey UTF8String];
	BIO *bio = BIO_new_mem_buf((void *)privkeyCString, -1);
	PEM_read_bio_DSAPrivateKey(bio, &dsa, NULL, NULL);
	BOOL result = YES;
	if (!dsa->priv_key) {
		self.lastError = @"Unable to decode key";
		result = NO;
	}
	// Cleanup BIO
	BIO_vfree(bio);
	return result;
}

- (BOOL)generate {
	if (![regName length] || !dsa || !dsa->priv_key)
		return NO;
	NSData *digest = [regName sha1];
	unsigned int siglen;
	unsigned char sig[100];
	int check = DSA_sign(NID_sha1, [digest bytes], [digest length], sig, &siglen, dsa);
	if (!check) {
		self.lastError = @"Signing failed";
		return NO;
	}
	// Encode signature in Base32
	NSData *signature = [NSData dataWithBytes:sig length:siglen];
	NSString *b32Orig = [signature base32];
	if (!b32Orig || ![b32Orig length]) {
		self.lastError = @"Unable to encode in base32";
		return NO;
	}
	// Replace Os with 8s and Is with 9s
	NSString *replacedOWith8 = [b32Orig stringByReplacingOccurrencesOfString:@"O" withString:@"8"];
	NSString *b32 = [replacedOWith8 stringByReplacingOccurrencesOfString:@"I" withString:@"9"];
	// Cut off the padding.
	NSString *regKeyNoPadding = [b32 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
	// Add dashes every 5 characters.
	NSMutableString *serial = [NSMutableString stringWithString:regKeyNoPadding];
	NSUInteger index = 5;
	while (index < [serial length]) {
		[serial insertString:@"-" atIndex:index];
		index += 6;
	}
	self.regCode = serial;
	return YES;
}

#pragma mark -
#pragma mark OpenSSL Lifecycle

- (void)initOpenSSL {
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
}

- (void)shutdownOpenSSL {
	EVP_cleanup();
	ERR_free_strings();
}

@end
