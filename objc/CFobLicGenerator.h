//
//  PxLicGenerator.h
//  pxlic
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd.
//  Copyright 2009 PixelEspresso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/dsa.h>

@interface PxLicGenerator : NSObject {
    DSA *dsa;
    NSString *regName;
    NSString *regKey;
    NSString *lastError;
}

@property (nonatomic, copy) NSString *regName;
@property (nonatomic, copy) NSString *regKey;
@property (nonatomic, copy) NSString *lastError;

+ (id)generatorWithPrivateKey:(NSString *)privKey;

- (id)initWithPrivateKey:(NSString *)privKey;
- (BOOL)setPrivateKey:(NSString *)privKey;
- (BOOL)generate;

@end
