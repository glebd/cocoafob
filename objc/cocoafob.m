//
// cocoafob.m
// CocoaFob Test Utility
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd.
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import <Foundation/Foundation.h>

#import <CocoaFob/CFobLicGenerator.h>
#import <CocoaFob/CFobLicVerifier.h>

//#define TEST

#ifdef TEST
// This function just generates a registration code and then verifies it.
void smoketest()
{
	// No need to obfuscate this as you won't ever distribute your private key.
	NSString *privKey = @"-----BEGIN DSA PRIVATE KEY-----\n"
	"MIH5AgEAAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6oyEv7Y2oT3itY5pbO\n"
	"bgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10PhoV6zczFpi3C7FzWN\n"
	"AkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40nkFNsK1OVwjo2ocn\n"
	"3MwW4Rdq6uLm3DlENRZ5bYrTAkEA4reDYZKAl1vx+8EIMP/+2Z7ekydHfX0sTMDg\n"
	"kxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOry8MoDQIVAIXgAB9GBLh4\n"
	"keUwLHBtpClnD5E8\n"
	"-----END DSA PRIVATE KEY-----\n";
	NSString *regName = @"decloner|Joe Bloggs";
	CFobLicGenerator *generator = [CFobLicGenerator generatorWithPrivateKey:privKey];
	generator.regName = regName;
	[generator generate];
	
	// Modelled after AquaticPrime's method of splitting public key to obfuscate it.
	// It is probably better if you invent your own splitting pattern. Go wild.
	NSMutableString *pubKeyBase64 = [NSMutableString string];
	[pubKeyBase64 appendString:@"MIHxMIGoBgcqhkj"];
	[pubKeyBase64 appendString:@"OOAQBMIGcAkEA8wm04e0QcQRoAVJW"];
	[pubKeyBase64 appendString:@"WnUw/4rQEKbLKjujJu6o\n"];
	[pubKeyBase64 appendString:@"yE"];
	[pubKeyBase64 appendString:@"v7Y2oT3itY5pbObgYCHEu9FBizqq7apsWYSF3YX"];
	[pubKeyBase64 appendString:@"iRjKlg10wIVALfs9eVL10Ph\n"];
	[pubKeyBase64 appendString:@"oV6zczFpi3C7FzWNAkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw"];
	[pubKeyBase64 appendString:@"/BCC13IAsW40\n"];
	[pubKeyBase64 appendString:@"nkFNsK1OVwjo2ocn"];
	[pubKeyBase64 appendString:@"3M"];
	[pubKeyBase64 appendString:@"wW"];
	[pubKeyBase64 appendString:@"4Rdq6uLm3DlENRZ5bYrTA"];
	[pubKeyBase64 appendString:@"0QAAkEA4reDYZKAl1vx+8EI\n"];
	[pubKeyBase64 appendString:@"MP/+"];
	[pubKeyBase64 appendString:@"2Z7ekydHfX0sTMDgkxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOr\n"];
	[pubKeyBase64 appendString:@"y8MoDQ==\n"];
	NSString *pubKey = [CFobLicVerifier completePublicKeyPEM:pubKeyBase64];
	CFobLicVerifier *verifier = [CFobLicVerifier verifierWithPublicKey:pubKey];
	verifier.regName = regName;
	verifier.regCode = generator.regCode;
	puts([verifier.regCode UTF8String]);
	if ([verifier verify])
		puts("PASS");
	else
		puts("FAIL");
}
#endif

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
	
	puts("CocoaFob Command Line Utility Version 1.0b3");

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
