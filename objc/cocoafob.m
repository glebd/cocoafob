//
// cocoafob.m
// CocoaFob Test Utility
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @glebd.
//  Copyright (C) 2009-2012 PixelEspresso. All rights reserved.
//  BSD License
//

#import <Foundation/Foundation.h>

#import <CocoaFob/CFobLicGenerator.h>
#import <CocoaFob/CFobLicVerifier.h>

// Pass private key file name and registration name string to generate an autoreleased string containing registration code.
NSString *codegen(NSString *privKeyFileName, NSString *regName) 
{
    NSError *err = nil;
	NSString *privKey = [NSString stringWithContentsOfFile:privKeyFileName encoding:NSASCIIStringEncoding error:&err];
	if (privKey == nil)
		return nil;
	
	CFobLicGenerator *generator = [[[CFobLicGenerator alloc] init] autorelease];
	if (![generator setPrivateKey:privKey error:&err]) {
		NSLog(@"%@", err);
		return nil;
	}
	
	NSString *regCode = [generator generateRegCodeForName:regName error:&err];
	if (regCode == nil) {
		NSLog(@"%@", err);
		return nil;
	}
	
	return regCode;
}

// Pass public key, registration name and registration code to verify it
BOOL codecheck(NSString *pubKeyFileName, NSString *regName, NSString *regCode)
{
    NSError *err = nil;
	NSString *pubKey = [NSString stringWithContentsOfFile:pubKeyFileName encoding:NSASCIIStringEncoding error:&err];
	if (pubKey == nil)
		return NO;
	
	CFobLicVerifier *verifier = [[[CFobLicVerifier alloc] init] autorelease];
	if (![verifier setPublicKey:pubKey error:&err]) {
		NSLog(@"%@", err);
		return NO;
	}
	
	BOOL result = [verifier verifyRegCode:regCode forName:regName error:&err];
	if (!result)
		NSLog(@"%@", err);

    return result;
}

// Uses NSUserDefaults to parse command-line arguments:
// -privkey <private-key-file-name>
// -name <registration-name>
// Prints generated registration code.
// -pubkey <public-key-file-name>
// -code <registration-code>
// Verifies registration code.
int main(int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	puts("CocoaFob Command Line Utility Version 2.0");

#ifdef TEST
	smoketest();
#endif
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	NSString *privKeyFileName = [args stringForKey:@"privkey"];
	NSString *pubKeyFileName = [args stringForKey:@"pubkey"];
	NSString *regName = [args stringForKey:@"name"];
    NSString *regCodeIn = [args stringForKey:@"code"];
	if (!((privKeyFileName && regName) || (pubKeyFileName && regName && regCodeIn))) {
		puts("Usage: cocoafob {-privkey <priv-key-file> -name <reg-name>|-pubkey <pub-key-file> -name <reg-name> -code <reg-code>}");
		return 1;
	}
    int retval = 0;
    if (regCodeIn && pubKeyFileName && regName) {
        // Verify supplied registration code
        BOOL check = codecheck(pubKeyFileName, regName, regCodeIn);
        if (check) {
            puts("OK");
        } else {
            puts("Error");
            retval = 3;
        }
    } else {
        // Generate registration code
        NSString *regCode = codegen(privKeyFileName, regName);
        if (!regCode) {
            puts("Error");
            retval = 2;
        } else {
            puts([regCode UTF8String]);
        }
    }
	[pool drain];
	return retval;
}
