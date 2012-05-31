//
//  CFobLicVerifier.h
//  CocoaFob
//
//  Created by Gleb Dolgich on 06/02/2009.
//  Follow me on Twitter @glebd.
//  Copyright 2009-2012 PixelEspresso. All rights reserved.
//  Licensed under BSD license.
//

#import <Foundation/Foundation.h>
#import <openssl/dsa.h>

/*!
	@class       CFobLicVerifier
	@superclass  NSObject
	@abstract    Verifies CocoaFob-style registration key.
	@discussion  Verifies CocoaFob-style registration key given licensing information (for example, application name, user name, and number of copies as suggested in Potion Store) and signature in human-readable format. A signature is a base32-encoded bignum with padding removed and dashes inserted.
*/
@interface CFobLicVerifier : NSObject {
	DSA *_dsa;
	NSArray *_blacklist;
}

@property (nonatomic, copy) NSArray *blacklist;

/*!
    @method     initOpenSSL
    @abstract   Inits OpenSSL library
    @discussion Must be called before any other calls to the class methods. The current implementation calls this method automatically when the class is instantiated for the first time.
 */
+ (void)initOpenSSL;

/*!
    @method     shutdownOpenSSL
    @abstract   Shuts down OpenSSL library
    @discussion Must be called on app exit. Be careful not to call this method while OpenSSL library is still being used.
 */
+ (void)shutdownOpenSSL;

/*!
	@method     completePublicKeyPEM:
	@abstract   Adds header and footer to incomplete PEM text.
	@discussion When storing a hard-coded PEM-encoded key in the application source, precautions are needed against easy replacement of the key. One way is to construct the key's PEM encoding step by step, appending each line to a mutable string until the base64-encoded part of the key is complete. You can then pass the base64-encoded key to this function and get complete PEM-encoded key as the result, with BEGIN and END lines added.
	@param      partialPEM Base64-encoded part of the PEM key without BEGIN or END lines.
	@result     An autoreleased string containing complete PEM-encoded DSA public key.
*/
+ (NSString *)completePublicKeyPEM:(NSString *)partialPEM;

/*!
	@method     setPubKey:
	@abstract   Sets DSA public key to the passed key in PEM format.
	@discussion Sets DSA public key in the verifier object to the argument which is a PEM-encoded DSA public key.
	@param      pubKey PEM-encoded DSA public key.
	@result     YES on success, NO on error (err may or may not be populated).
*/
- (BOOL)setPublicKey:(NSString *)pubKey error:(NSError **)err;

/*!
	@method     verify
	@abstract   Verifies registration code in the regName property using public DSA key.
	@discussion Takes regName and regCode properties and verifies regCode against regName using public DSA certificate.
	@result     YES if regCode is valid, NO if not. If an error was recovered it will be set in the err parameter
*/
- (BOOL)verifyRegCode:(NSString *)regCode forName:(NSString *)name error:(NSError **)err;

@end
