// Copyright (c) 2006 Dave Dribin (http://www.dribin.org/dave/)
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// Modified by Gleb Dolgich @gbd
// PixelEspresso, http://www.pixelespressoapps.com/

#import "NSString-Base64Extensions.h"
#import <Security/Security.h>

@implementation NSString (Base64)

- (NSData *) decodeBase64;
{
    return [self decodeBase64WithNewlines: YES];
}

- (NSData *)decodeBase64WithNewlines:(BOOL)encodedWithNewlines;
{
    SecTransformRef transform = SecDecodeTransformCreate(kSecBase64Encoding, NULL);
    NSData *output = nil;
    if (SecTransformSetAttribute(transform, kSecTransformInputAttributeName, [self dataUsingEncoding:NSASCIIStringEncoding], NULL)) {
        output = (NSData *)SecTransformExecute(transform, NULL);
    }
    [output autorelease];
    CFRelease(transform);
    return output;
}

@end
