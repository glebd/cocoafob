//
// cocoafob.m
// CocoaFob Test Utility
//
//  Created by Gleb Dolgich on 09/02/2009.
//  Follow me on Twitter @gbd.
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License <http://creativecommons.org/licenses/by/3.0/>
//

#import <Foundation/Foundation.h>
#import "CFobLicGenerator.h"
#import "CFobLicVerifier.h"

void test() {
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
	
	// AquaticPrime uses this method to obfuscate public key embedded in the source.
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

NSString *codegen(NSString *privKeyFileName, NSString *regName) {
	NSString *privKey = [NSString stringWithContentsOfFile:privKeyFileName];
	if (!privKey)
		return nil;
	CFobLicGenerator *generator = [CFobLicGenerator generatorWithPrivateKey:privKey];
	generator.regName = regName;
	if (![generator generate])
		return nil;
	return generator.regCode;
}

int main(int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	puts("CocoaFob Command Line Utility Version 1.0b1");

	//test();
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	NSString *privKeyFileName = [args stringForKey:@"privkey"];
	NSString *regName = [args stringForKey:@"name"];
	if (!privKeyFileName || !regName) {
		puts("Usage: cocoafob -privkey <priv-key-file> -name <reg-name>");
		return 1;
	}
	NSString *regCode = codegen(privKeyFileName, regName);
	if (!regCode)
		puts("Error");
	else
		puts([regCode UTF8String]);
	[pool drain];
	return 0;
}
