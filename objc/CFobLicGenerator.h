//
//  CFobLicGenerator.h
//  CocoaFob
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @glebd.
//  Copyright (C) 2009-2015 PixelEspresso. All rights reserved.
//  BSD License
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

/*!
	@class       CFobLicGenerator 
	@superclass  NSObject
	@abstract    Generates CocoaFob-style registration codes.
	@discussion  Given user name and DSA private key, generates a human-readable registration code.
*/
@interface CFobLicGenerator : NSObject {
	SecKeyRef _privateKey;
}

/*!
	@method     setPrivateKey:
	@abstract   Sets a new DSA private key.
	@discussion Sets a new DSA private key to be used for subsequent generated registration codes.
	@param      privKey PEM-encoded non-encrypted DSA private key.
	@result     YES on success, NO on error.
*/
- (BOOL)setPrivateKey:(NSString *)privKey error:(NSError **)err;

/*!
	@method     generate
	@abstract   Generates a registration code from regName property.
	@discussion Takes regName property and DSA private key and generates a new registration code that is placed in regCode property.
	@param		The name or registration string to generate a serial number for.
	@result     The serial number as a string, nil on failure.
*/
- (NSString *)generateRegCodeForName:(NSString *)name error:(NSError **)err;

@end
