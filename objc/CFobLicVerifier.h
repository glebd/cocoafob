//
//  PxLicVerifier.h
//  pxlic
//
//  Created by Gleb Dolgich on 06/02/2009.
//  Follow me on Twitter @gbd.
//  Copyright 2009 PixelEspresso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/dsa.h>

/*!
    @class       PxLicVerifier 
    @superclass  NSObject
    @abstract    Verifies PxLic-style registration key.
    @discussion  Verifies PxLic-style registration key given licensing information (application name, user name, and number of copies as suggested in Potion Store) and signature in human-readable format. A signature is a base32-encoded bignum with padding removed and dashes inserted.
*/
@interface PxLicVerifier : NSObject {
    DSA *dsa;
    NSString *regName;
    NSString *regKey;
    NSArray *blacklist;
    NSString *lastError;
}

@property (nonatomic, copy) NSString *regName;
@property (nonatomic, copy) NSString *regKey;
@property (nonatomic, retain) NSArray *blacklist;
@property (nonatomic, copy) NSString *lastError;

/*!
    @method     verifierWithPublicKey:
    @abstract   Creates a new PxLic verifier object given a DSA public key.
    @discussion Creates a new PxLic verifier object. Use setRegName: and setRegKey: on it, then call verify to verify registration key.
    @param      pubKey A DSA public key in PEM encoding. See completePublicKeyPEM: for help on how to construct a PEM-encoded DSA public key.
    @result     A new autoreleased PxLic verifier object.
*/
+ (id)verifierWithPublicKey:(NSString *)pubKey;

/*!
    @method     completePublicKeyPEM:
    @abstract   Adds header and footer to incomplete PEM text.
    @discussion When storing a hard-coded PEM-encoded key in the application source, precautions are needed against easy replacement of the key. One way is to construct the key's PEM encoding step by step, appending each line to a mutable string until the base64-encoded part of the key is complete. You can then pass the base64-encoded key to this function and get complete PEM-encoded key as the result, with BEGIN and END lines added.
    @param      partialPEM Base64-encoded part of the PEM key without BEGIN or END lines.
    @result     An autoreleased string containing complete PEM-encoded DSA public key.
*/
+ (NSString *)completePublicKeyPEM:(NSString *)partialPEM;

/*!
    @method     initWithPublicKey:
    @abstract   Designated initialiser.
    @discussion Initialises a newly allocated PxLicVerifier object with a PEM-encoded DSA public key.
    @param      pubKey A PEM-encoded DSA public key. See completePublicKeyPEM: for help on how to constuct a PEM-encoded DSA key string from base64-encoded lines.
    @result     An initialised PxLicVerifier object.
*/
- (id)initWithPublicKey:(NSString *)pubKey;

/*!
    @method     setPubKey:
    @abstract   Sets DSA public key to the passed key in PEM format.
    @discussion Sets DSA public key in the verifier object to the argument which is a PEM-encoded DSA public key.
    @param      pubKey PEM-encoded DSA public key.
    @result     YES on success, NO on error (check lastError property).
*/
- (BOOL)setPublicKey:(NSString *)pubKey;
- (BOOL)verify;

@end
