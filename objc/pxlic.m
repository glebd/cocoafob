#import <Foundation/Foundation.h>
#import "PxLicGenerator.h"
#import "PxLicVerifier.h"

void test() {
    NSString *privKey = @"-----BEGIN DSA PRIVATE KEY-----\nMIH4AgEAAkEApuYqEoIJcs8reEItoKJusdZEaeCU71pSUU8BjVXK/K4J5/tUnmmk\nS7JkhUjK7CP882sI1kTHEXaxIjAXVX74nQIVAL45/aSf+Mn2zhlPojZnjRchrQFV\nAkBoFzzLEHVaPa3qxMNXE27jGtqyZK/n3uTTa0eBflGPE4STA85JNVUFlsYrbxVh\nwy9QdfmGERgJupg+cxxIVmGRAkEAk8ZRoFZ5otEG+bfkkufh43/lYSLPz4dazRvp\naRWcbaatbNb6ojmAiXMdVHQSRgq+bHpTrA8CDAvyw/UeDpYO9gIUKXizaRlSWbB0\ngkb+zRrNLgk/XqM=\n-----END DSA PRIVATE KEY-----\n";
    NSString *regName = @"product,User Name";
    PxLicGenerator *generator = [PxLicGenerator generatorWithPrivateKey:privKey];
    generator.regName = regName;
    [generator generate];
    
    NSMutableString *pubKey = [NSMutableString string];
    [pubKey appendString:@"MIHxMIGoBgcqhkjOOAQBMIGcAkEApuYqEoIJcs8reEItoKJusdZEaeCU71pSUU8B\n"];
    [pubKey appendString:@"jVXK/K4J5/tUnmmkS7JkhUjK7CP882sI1kTHEXaxIjAXVX74nQIVAL45/aSf+Mn2\n"];
    [pubKey appendString:@"zhlPojZnjRchrQFVAkBoFzzLEHVaPa3qxMNXE27jGtqyZK/n3uTTa0eBflGPE4ST\n"];
    [pubKey appendString:@"A85JNVUFlsYrbxVhwy9QdfmGERgJupg+cxxIVmGRA0QAAkEAk8ZRoFZ5otEG+bfk\n"];
    [pubKey appendString:@"kufh43/lYSLPz4dazRvpaRWcbaatbNb6ojmAiXMdVHQSRgq+bHpTrA8CDAvyw/Ue\n"];
    [pubKey appendString:@"DpYO9g==\n"];
    NSString *pem = [PxLicVerifier completePublicKeyPEM:pubKey];
    PxLicVerifier *verifier = [PxLicVerifier verifierWithPublicKey:pem];
    verifier.regName = regName;
    //verifier.regKey = @"GAWAE-FD6V7-7CQ8M-UJ5X2-8CPHW-L5BN8-NRLZY-DMXAC-CQEH3-SMF6C-AYTJK-6LT9U-8DAAN-EG9WW-592Y";
    verifier.regKey = generator.regKey;
    if ([verifier verify])
        printf("PASS");
    else
        printf("FAIL");
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    test();
    
    [pool drain];
    return 0;
}
