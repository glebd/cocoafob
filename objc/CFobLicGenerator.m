//
//  CFobLicGenerator.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @glebd.
//  Copyright (C) 2009-2012 PixelEspresso. All rights reserved.
//  BSD License
//

#import "CFobLicGenerator.h"

#import "CFobError.h"

#import "NSData+PECrypt.h"
#import "NSString+PECrypt.h"

#import <openssl/evp.h>
#import <openssl/err.h>
#import <openssl/pem.h>

//***************************************************************************

@interface CFobLicGenerator ()

@property (nonatomic, assign) DSA *dsa;

- (void)initOpenSSL;
- (void)shutdownOpenSSL;

@end


@implementation CFobLicGenerator

@synthesize dsa = _dsa;

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	[self initOpenSSL];

	return self;
}

#if !__has_feature(objc_arc)
- (void)finalize
{
	if (self.dsa)
		DSA_free(self.dsa);
	
	[self shutdownOpenSSL];
	[super finalize];
}
#endif

- (void)dealloc 
{
	if (self.dsa)
		DSA_free(self.dsa);
	
	[self shutdownOpenSSL];
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

#pragma mark -
#pragma mark API

- (BOOL)setPrivateKey:(NSString *)privKey error:(NSError **)err
{	
	// Validate the argument.
	if (privKey == nil || [privKey length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid private key.", CFobErrorCodeInvalidKey);
		return NO;
	}
	
	if (self.dsa)
		DSA_free(self.dsa);
	self.dsa = DSA_new();
	// Prepare BIO to read PEM-encoded private key from memory.
	// Prepare buffer given NSString.
	const char *privkeyCString = [privKey UTF8String];
	BIO *bio = BIO_new_mem_buf((void *)privkeyCString, -1);
	PEM_read_bio_DSAPrivateKey(bio, &_dsa, NULL, NULL);
	BOOL result = YES;
	if (!self.dsa->priv_key) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Unable to decode key.", CFobErrorCodeCouldNotDecode);
		result = NO;
	}
	// Cleanup BIO
	BIO_vfree(bio);
	return result;
}

- (NSString *)generateRegCodeForName:(NSString *)name error:(NSError **)err
{
	if (name == nil || [name length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"No name provided.", CFobErrorCodeNoName);
		return nil;
	}
	
	if (!self.dsa || !self.dsa->priv_key) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid private key.", CFobErrorCodeInvalidKey);
		return nil;
	}
	
	NSData *digest = [name sha1];
	unsigned int siglen;
	unsigned char sig[100];
	int check = DSA_sign(NID_sha1, [digest bytes], [digest length], sig, &siglen, self.dsa);
	if (!check) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Signing failed.", CFobErrorCodeSigningFailed);
		return nil;
	}
	
	// Encode signature in Base32
	NSData *signature = [NSData dataWithBytes:sig length:siglen];
	NSString *b32Orig = [signature base32];
	if (!b32Orig || ![b32Orig length]) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Unable to encode in base32", CFobErrorCodeCouldNotEncode);
		return nil;
	}
	
	// Replace Os with 8s and Is with 9s
	NSString *replacedOWith8 = [b32Orig stringByReplacingOccurrencesOfString:@"O" withString:@"8"];
	NSString *b32 = [replacedOWith8 stringByReplacingOccurrencesOfString:@"I" withString:@"9"];
	
	// Cut off the padding.
	NSString *regKeyNoPadding = [b32 stringByReplacingOccurrencesOfString:@"=" withString:@""];
	
	// Add dashes every 5 characters.
	NSMutableString *serial = [NSMutableString stringWithString:regKeyNoPadding];
	NSUInteger index = 5;
	while (index < [serial length]) {
		[serial insertString:@"-" atIndex:index];
		index += 6;
	}

	return serial;
}

#pragma mark -
#pragma mark OpenSSL Lifecycle

- (void)initOpenSSL 
{
	OpenSSL_add_all_algorithms();
	ERR_load_crypto_strings();
}

- (void)shutdownOpenSSL 
{
	EVP_cleanup();
	ERR_free_strings();
}

@end
