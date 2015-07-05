//
//  CFobLicGenerator.m
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @glebd.
//  Copyright (C) 2009-2015 PixelEspresso. All rights reserved.
//  BSD License
//

#import "CFobLicGenerator.h"
#import "CFobError.h"

@interface CFobLicGenerator ()
@property (retain) __attribute__((NSObject)) SecKeyRef privateKey;
@end


@implementation CFobLicGenerator

@synthesize privateKey = _privateKey;

#pragma mark -
#pragma mark Lifecycle

#if !__has_feature(objc_arc)
- (void)finalize
{
    self.privateKey = nil;
	[super finalize];
}

- (void)dealloc
{
	[super dealloc];
}
#endif

#pragma mark -
#pragma mark API

- (BOOL)setPrivateKey:(NSString *)privKey error:(NSError **)err
{
	self.privateKey = nil;

	// Validate the argument.
	if (privKey == nil || [privKey length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid private key.", CFobErrorCodeInvalidKey);
		return NO;
	}

	SecItemImportExportKeyParameters params = {};
	SecExternalItemType keyType = kSecItemTypePrivateKey;
	SecExternalFormat keyFormat = kSecFormatPEMSequence;
	CFArrayRef importArray = NULL;

	NSData *privKeyData = [privKey dataUsingEncoding:NSUTF8StringEncoding];
#if __has_feature(objc_arc)
	CFDataRef privKeyDataRef = (__bridge CFDataRef)privKeyData;
#else
	CFDataRef privKeyDataRef = (CFDataRef)privKeyData;
#endif

	OSStatus importError = SecItemImport(privKeyDataRef, NULL, &keyFormat, &keyType, 0, &params, NULL, &importArray);
	if (importError) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Unable to decode key.", CFobErrorCodeCouldNotDecode);
		if (importArray) {
			CFRelease(importArray);
		}
		return NO;
	}

	self.privateKey = (SecKeyRef)CFArrayGetValueAtIndex(importArray, 0);
	CFRelease(importArray);
	return YES;
}

- (NSString *)generateRegCodeForName:(NSString *)name error:(NSError **)err
{
	if (name == nil || [name length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"No name provided.", CFobErrorCodeNoName);
		return nil;
	}
	
	if (!self.privateKey) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid private key.", CFobErrorCodeInvalidKey);
		return nil;
	}

	NSData *keyData = nil;
	NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
#if __has_feature(objc_arc)
	CFDataRef nameDataRef = (__bridge CFDataRef)nameData;
#else
	CFDataRef nameDataRef = (CFDataRef)nameData;
#endif

	SecGroupTransformRef group = SecTransformCreateGroupTransform();
	SecTransformRef signer = SecSignTransformCreate(self.privateKey, NULL);
	if (signer) {
		SecTransformSetAttribute(signer, kSecTransformInputAttributeName, nameDataRef, NULL);
		SecTransformSetAttribute(signer, kSecDigestTypeAttribute, kSecDigestSHA1, NULL);
		SecTransformRef encoder = SecEncodeTransformCreate(kSecBase32Encoding, NULL);
		if (encoder) {
			SecTransformConnectTransforms(signer, kSecTransformOutputAttributeName, encoder, kSecTransformInputAttributeName, group, NULL);
#if __has_feature(objc_arc)
			keyData = (NSData *)CFBridgingRelease(SecTransformExecute(group, NULL));
#else
			keyData = [(NSData *)SecTransformExecute(group, NULL) autorelease];
#endif
			CFRelease(encoder);
		}
		CFRelease(signer);
	}
	CFRelease(group);

	if (!keyData) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Signing failed.", CFobErrorCodeSigningFailed);
		return nil;
	}

	NSString *b32Orig = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
#if !__has_feature(objc_arc)
	[b32Orig autorelease];
#endif

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

@end
