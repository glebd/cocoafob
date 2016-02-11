//
//  CFobLicVerifier-HeaderOnly.h
//  cocoafob
//
//  Created by Daniel Alm on 24.11.15.
//  Copyright 2009-2015 PixelEspresso, Daniel Alm. All rights reserved.
//  Licensed under BSD license.
//

#ifndef CFobLicVerifier_HeaderOnly_h
#define CFobLicVerifier_HeaderOnly_h

#import <Foundation/Foundation.h>
#import <Security/Security.h>

enum _CFobErrorCode {
	CFobErrorCodeInvalidKey = -1,
	CFobErrorCodeCouldNotDecode = -2,
	CFobErrorCodeSigningFailed = -3,
	CFobErrorCodeCouldNotEncode = -4,
	CFobErrorCodeNoName = -5,
};

static inline void CFobAssignErrorWithDescriptionAndCode(NSError **err, NSString *description, NSInteger code)
{
	if (err != NULL)
		*err = [NSError errorWithDomain:@"cocoafob" code:code userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
}

static inline NSString *CFobCompletePublicKeyPEM(NSString *partialPEM) {
	NSString *dashes = @"-----";
	NSString *begin = @"BEGIN";
	NSString *end = @"END";
	NSString *key = @"KEY";
	NSString *public = @"DSA PUBLIC";
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

static inline SecKeyRef CFobSetPublicKey(NSString *pubKey, NSError **err) {
	// Validate the argument.
	if (pubKey == nil || [pubKey length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Invalid key.", CFobErrorCodeInvalidKey);
		return NULL;
	}

	SecItemImportExportKeyParameters params = {};
	SecExternalItemType keyType = kSecItemTypePublicKey;
	SecExternalFormat keyFormat = kSecFormatPEMSequence;
	CFArrayRef importArray = NULL;

	NSData *pubKeyData = [pubKey dataUsingEncoding:NSUTF8StringEncoding];
	CFDataRef pubKeyDataRef = (__bridge CFDataRef)pubKeyData;

	OSStatus importError = SecItemImport(pubKeyDataRef, NULL, &keyFormat, &keyType, 0, &params, NULL, &importArray);

	if (importError) {
		CFobAssignErrorWithDescriptionAndCode(err, @"Unable to decode key.", CFobErrorCodeCouldNotDecode);
		if (importArray) {
			CFRelease(importArray);
		}
		return NULL;
	}

	SecKeyRef keyRef = (SecKeyRef)CFRetain(CFArrayGetValueAtIndex(importArray, 0));
	CFRelease(importArray);
	return keyRef;
}

static inline BOOL CFobVerifyRegCode(SecKeyRef keyRef, NSString *regCode, NSString *name, NSError **err) {
	if (name == nil || [name length] < 1) {
		CFobAssignErrorWithDescriptionAndCode(err, @"No name for the registration code.", CFobErrorCodeNoName);
		return NO;
	}

	// Replace 9s with Is and 8s with Os
	NSString *regKeyTemp = [regCode stringByReplacingOccurrencesOfString:@"9" withString:@"I"];
	NSString *regKeyBase32 = [regKeyTemp stringByReplacingOccurrencesOfString:@"8" withString:@"O"];
	// Remove dashes from the registration key if they are there (dashes are optional).
	NSString *keyNoDashes = [regKeyBase32 stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSData *keyData = [keyNoDashes dataUsingEncoding:NSUTF8StringEncoding];
	NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
	CFDataRef keyDataRef = (__bridge CFDataRef)keyData;
	CFDataRef nameDataRef = (__bridge CFDataRef)nameData;

	// Note: A transform group is not used here because there appears to be a bug connecting the output of a decode transform to kSecSignatureAttributeName. Execution of the group randomly fails.

	BOOL result = NO;
	SecTransformRef decoder = SecDecodeTransformCreate(kSecBase32Encoding, NULL);
	if (decoder) {
		SecTransformSetAttribute(decoder, kSecTransformInputAttributeName, keyDataRef, NULL);
		CFDataRef signature = SecTransformExecute(decoder, NULL);
		if (signature) {
			SecTransformRef verifier = SecVerifyTransformCreate(keyRef, signature, NULL);
			if (verifier) {
				SecTransformSetAttribute(verifier, kSecTransformInputAttributeName, nameDataRef, NULL);
				SecTransformSetAttribute(verifier, kSecDigestTypeAttribute, kSecDigestSHA1, NULL);
				CFErrorRef error;
				CFBooleanRef transformResult = SecTransformExecute(verifier, &error);
				if (transformResult) {
					result = (transformResult == kCFBooleanTrue);
					CFRelease(transformResult);
				}
				CFRelease(verifier);
			}
			CFRelease(signature);
		}
		CFRelease(decoder);
	}
	return result;
}

static inline BOOL CFobIsRegistered(NSString *partialPEM, NSString *regCode, NSString *name, NSError **err) {
	NSString *publicKey = CFobCompletePublicKeyPEM(partialPEM);
	SecKeyRef keyRef = CFobSetPublicKey(publicKey, err);
	if (!keyRef) return NO;
	BOOL result = CFobVerifyRegCode(keyRef, regCode, name, err);
	CFRelease(keyRef);
	return result;
}

#endif /* CFobLicVerifier_HeaderOnly_h */
