//
//  CocoaFobTests.m
//  CocoaFobTests
//
//  Created by Gleb Dolgich on 01/09/2012.
//  Twitter: @glebd
//  Website: http://pixelespressoapps.com
//
//  License: BSD
//
//

#import "CocoaFobTests.h"

#import "CFobLicGenerator.h"
#import "CFobLicVerifier.h"

@interface CocoaFobTests ()
@property (nonatomic, strong) CFobLicGenerator *generator;
@property (nonatomic, strong) CFobLicVerifier *verifier;
@property (nonatomic, strong) NSString *pubKey;
@end

@implementation CocoaFobTests

static NSString *privKey = @"-----BEGIN DSA PRIVATE KEY-----\n"
"MIH5AgEAAkEA8wm04e0QcQRoAVJWWnUw/4rQEKbLKjujJu6oyEv7Y2oT3itY5pbO\n"
"bgYCHEu9FBizqq7apsWYSF3YXiRjKlg10wIVALfs9eVL10PhoV6zczFpi3C7FzWN\n"
"AkBaPhALEKlgIltHsumHdTSBqaVoR1/bmlgw/BCC13IAsW40nkFNsK1OVwjo2ocn\n"
"3MwW4Rdq6uLm3DlENRZ5bYrTAkEA4reDYZKAl1vx+8EIMP/+2Z7ekydHfX0sTMDg\n"
"kxhtRm6qtcywg01X847Y9ySgNepqleD+Ka2Wbucj1pOry8MoDQIVAIXgAB9GBLh4\n"
"keUwLHBtpClnD5E8\n"
"-----END DSA PRIVATE KEY-----\n";

static NSString *regName = @"decloner|Joe Bloggs";

- (void)setUp
{
	[super setUp];

	self.generator = [[CFobLicGenerator alloc] init];

	NSError *err = nil;
	if (![self.generator setPrivateKey:privKey error:&err]) {
		STFail(@"Could not set up private key: %@", err);
	}

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

	self.pubKey = [CFobLicVerifier completePublicKeyPEM:pubKeyBase64];

	self.verifier = [[CFobLicVerifier alloc] init];
	if (![self.verifier setPublicKey:self.pubKey error:&err]) {
		STFail(@"Could not set public key on verifier %@", err);
	}
}

- (void)tearDown
{
	[super tearDown];
}

- (void)testGenerateAndVerify
{
	NSError *err = nil;
	NSString *regCode = [self.generator generateRegCodeForName:regName error:&err];
	STAssertNotNil(regCode, @"Could not generate serial number: %@", err);

	BOOL result = [self.verifier verifyRegCode:regCode forName:regName error:&err];
	STAssertTrue(result, @"Registration code could not be verified: %@", err);
}

- (void)testVerify
{
	NSError *err = nil;
	BOOL result = [self.verifier verifyRegCode:@"GAWQE-F9AQP-XJCCL-PAFAX-NU5XX-EUG6W-KLT3H-VTEB9-A9KHJ-8DZ5R-DL74G-TU4BN-7ATPY-3N4XB-V4V27-Q" forName:@"Joe Bloggs" error:&err];
	STAssertTrue(result, @"Registration code could not be verified: %@", err);
}

@end
