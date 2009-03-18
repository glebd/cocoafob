//
//  CFobLicVerifier.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 06/02/2009.
//  Follow me on Twitter @gbd.
//  Copyright 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import "NSString-Base64Extensions.h"
#import "NSString+PECrypt.h"
#import "CFobLicVerifier.h"
#import "decoder.h"
#import <openssl/evp.h>
#import <openssl/err.h>
#import <openssl/pem.h>


@interface CFobLicVerifier ()
- (void)initOpenSSL;
- (void)shutdownOpenSSL;
@end


@implementation CFobLicVerifier

@synthesize regName;
@synthesize regCode;
@synthesize blacklist;
@synthesize lastError;

#pragma mark -
#pragma mark Class methods

+ (id)verifierWithPublicKey:(NSString *)pubKey {
	return [[[CFobLicVerifier alloc] initWithPublicKey:pubKey] autorelease];
}

+ (NSString *)completePublicKeyPEM:(NSString *)partialPEM {
	NSString *dashes = @"-----";
	NSString *begin = @"BEGIN";
	NSString *end = @"END";
	NSString *key = @"KEY";
	NSString *public = @"PUBLIC";
	NSMutableString *pem = [NSMutableString string];
	[pem appendString:dashes];
	[pem appendString:begin];
	[pem appendString:@" "];
	[pem appendString:public];
	[pem appendString:@" "];
	[pem appendString:key];
	[pem appendString:dashes];
	[pem appendString:@"\n"];
	[pem appendString:partialPEM];
	[pem appendString:dashes];
	[pem appendString:end];
	[pem appendString:@" "];
	[pem appendString:public];
	[pem appendString:@" "];
	[pem appendString:key];
	[pem appendString:dashes];
	[pem appendString:@"\n"];
	return [NSString stringWithString:pem];
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
	return [self initWithPublicKey:nil];
}

- (id)initWithPublicKey:(NSString *)pubKey {
	if (![super init])
		return nil;
	[self initOpenSSL];
	[self setPublicKey:pubKey];
	return self;
}

- (void)dealloc {
	if (dsa)
		DSA_free(dsa);
	self.regName = nil;
	self.regCode = nil;
	self.blacklist = nil;
	self.lastError = nil;
	[self shutdownOpenSSL];
	[super dealloc];
}

#pragma mark -
#pragma mark API

- (BOOL)setPublicKey:(NSString *)pubKey {
	// Validate the argument.
	if (!pubKey || ![pubKey length]) {
		self.lastError = @"Invalid key";
		return NO;
	}
	if (dsa)
		DSA_free(dsa);
	dsa = DSA_new();
	// Prepare BIO to read PEM-encoded public key from memory.
	// Prepare buffer given NSString
	const char *pubkeyCString = [pubKey UTF8String];
	BIO *bio = BIO_new_mem_buf((void *)pubkeyCString, -1);
	PEM_read_bio_DSA_PUBKEY(bio, &dsa, NULL, NULL);
	BOOL result = YES;
	if (!dsa->pub_key) {
		self.lastError = @"Unable to decode key";
		result = NO;
	}
	// Cleanup BIO
	BIO_vfree(bio);
	return result;
}

- (BOOL)verify {
	if (![regName length] || ![regCode length] || !dsa || !dsa->pub_key)
		return NO;
	BOOL result = NO;
	// Replace 9s with Is and 8s with Os
	NSString *regKeyTemp = [regCode stringByReplacingOccurrencesOfString:@"9" withString:@"I"];
	NSString *regKeyBase32 = [regKeyTemp stringByReplacingOccurrencesOfString:@"8" withString:@"O"];
	// Remove dashes from the registration key if they are there (dashes are optional).
	NSString *keyNoDashes = [regKeyBase32 stringByReplacingOccurrencesOfString:@"-" withString:@""];
	// Need to pad up to the nearest number divisible by 8.
	NSUInteger keyLength = [keyNoDashes length];
	int paddedLength = keyLength%8 ? (keyLength/8 + 1)*8 : keyLength;
	NSString *keyBase32 = [keyNoDashes stringByPaddingToLength:paddedLength withString:@"=" startingAtIndex:0];
	const char *keyBase32Utf8 = [keyBase32 UTF8String];
	if (!keyBase32Utf8)
		return NO;
	size_t base32Length = strlen(keyBase32Utf8);
	// Prepare a buffer for decoding base32-encoded signature.
	size_t decodeBufSize = base32_decoder_buffer_size(base32Length);
	unsigned char *sig = malloc(decodeBufSize);
	if (!sig)
		return NO;
	// Decode signature from Base32 to a byte buffer.
	size_t sigSize = base32_decode(sig, decodeBufSize, (unsigned char *)keyBase32Utf8, base32Length);
	if (!sigSize)
		self.lastError = @"Unable to decode registration key";
	// Produce a SHA-1 hash of the registration name string. This is what was signed during registration key generation.
	NSData *digest = [regName sha1];
	// Verify DSA signature.
	int check = DSA_verify(0, [digest bytes], [digest length], sig, sigSize, dsa);
	result = check > 0;
	// Cleanup
	free(sig);
	return result;
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
