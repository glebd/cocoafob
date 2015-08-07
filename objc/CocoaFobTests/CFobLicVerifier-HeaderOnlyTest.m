//
//  CFobLicVerifier-HeaderOnlyTest.m
//  cocoafob
//
//  Created by Daniel Alm on 24.11.15.
//
//

#import <XCTest/XCTest.h>

#import "CFobLicVerifier-HeaderOnly.h"

@interface CFobLicVerifier_HeaderOnlyTest : XCTestCase
@property (nonatomic, copy) NSString *partialPEM;
@end

@implementation CFobLicVerifier_HeaderOnlyTest

- (void)setUp
{
	[super setUp];

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

	self.partialPEM = pubKeyBase64;
}

- (void)testVerifyInHeader {
	[self measureBlock:^{
		NSError *error = nil;
		NSString *regCode = @"GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q";
		NSString *name = @"Joe Bloggs";
		XCTAssertTrue(CFobIsRegistered(self.partialPEM, regCode, name, &error));
		XCTAssertNil(error);

		XCTAssertFalse(CFobIsRegistered(self.partialPEM, regCode, @"Joe Bloggt", &error));
		XCTAssertFalse(CFobIsRegistered(self.partialPEM, @"GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-P", name, &error));
	}];
}

@end
