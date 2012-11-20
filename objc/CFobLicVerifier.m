//
//  CFobLicVerifier.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 06/02/2009.
//  Follow me on Twitter @glebd.
//  Copyright 2009-2012 PixelEspresso. All rights reserved.
//  Licensed under BSD license.
//

#import "CFobLicVerifier.h"

#import "CFobError.h"

#import "decoder.h"

#import "NSString-Base64Extensions.h"
#import "NSString+PECrypt.h"

#import <openssl/evp.h>
#import <openssl/err.h>
#import <openssl/pem.h>


@interface CFobLicVerifier ()

@property (nonatomic, assign) DSA *dsa;

@end


@implementation CFobLicVerifier

@synthesize blacklist = _blacklist;

@synthesize dsa = _dsa;

#pragma mark -
#pragma mark Class methods

+ (void)initialize
{
    [CFobLicVerifier initOpenSSL];
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

- (id)init
{
	if (!(self = [super init]))
		return nil;

	return self;
}

#if !__has_feature(objc_arc)
- (void)finalize
{
	if (self.dsa)
		DSA_free(self.dsa);
	[super finalize];
}
#endif

- (void)dealloc
{
	if (self.dsa)
		DSA_free(self.dsa);

#if !__has_feature(objc_arc)
	self.blacklist = nil;
	[super dealloc];
#endif
}

#pragma mark -
#pragma mark API

- (BOOL)setPublicKey:(NSString *)pubKey error:(NSError **)err
{
	// Validate the argument.
	if (pubKey == nil || [pubKey length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid key.", CFobErrorCodeInvalidKey);
		return NO;
	}

	if (self.dsa)
		DSA_free(self.dsa);
	self.dsa = DSA_new();

	// Prepare BIO to read PEM-encoded public key from memory.
	// Prepare buffer given NSString
	const char *pubkeyCString = [pubKey UTF8String];
	BIO *bio = BIO_new_mem_buf((void *)pubkeyCString, -1);
	PEM_read_bio_DSA_PUBKEY(bio, &_dsa, NULL, NULL);

	BOOL result = YES;
	if (!self.dsa->pub_key) {
        NSString *message = [NSString stringWithFormat:@"Unable to decode public key: %s", ERR_error_string(ERR_get_error (), NULL)];
		CFobAssignErrorWithDescriptionAndCode(err, message, CFobErrorCodeCouldNotDecode);
		result = NO;
	}

	// Cleanup BIO
	BIO_vfree(bio);
	return result;
}

- (BOOL)verifyRegCode:(NSString *)regCode forName:(NSString *)name error:(NSError **)err
{
	if (name == nil || [name length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"No name for the registration code.", CFobErrorCodeNoName);
		return NO;
	}

	if (!self.dsa || !self.dsa->pub_key) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid key.", CFobErrorCodeInvalidKey);
		return NO;
	}

	// Replace 9s with Is and 8s with Os
	NSString *regKeyTemp = [regCode stringByReplacingOccurrencesOfString:@"9" withString:@"I"];
	NSString *regKeyBase32 = [regKeyTemp stringByReplacingOccurrencesOfString:@"8" withString:@"O"];
	// Remove dashes from the registration key if they are there (dashes are optional).
	NSString *keyNoDashes = [regKeyBase32 stringByReplacingOccurrencesOfString:@"-" withString:@""];
	// Need to pad up to the nearest number divisible by 8.
	NSUInteger keyLength = [keyNoDashes length];
	NSUInteger paddedLength = keyLength%8 ? (keyLength/8 + 1)*8 : keyLength;
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
	if (!sigSize) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Unable to decode registration key.", CFobErrorCodeCouldNotDecode);
		free(sig);
		return NO;
	}

	// Produce a SHA-1 hash of the registration name string. This is what was signed during registration key generation.
	NSData *digest = [name sha1];

	// Verify DSA signature.
	int check = DSA_verify(0, [digest bytes], (int)[digest length], sig, (int)sigSize, self.dsa);
	BOOL result = check > 0;

	// Cleanup
	free(sig);
	return result;
}

#pragma mark -
#pragma mark OpenSSL Lifecycle

+ (void)initOpenSSL {
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
}

+ (void)shutdownOpenSSL {
	EVP_cleanup();
	ERR_free_strings();
}

@end
