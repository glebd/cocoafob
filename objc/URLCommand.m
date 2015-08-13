//
//  CocoaFob
//
//  URLCommand.h
//
//  Support for custom URL scheme for app registration.
//  Pay attention to the TODO: comments below.
//
//  Created by Gleb Dolgich on 20/03/2009.
//  Follow me on Twitter @glebd
//  Copyright (C) 2009 PixelEspresso. All rights reserved.
//  Licensed under CC Attribution License 3.0 <http://creativecommons.org/licenses/by/3.0/>
//
//  Based on "Handling URL schemes in Cocoa", a blog post by Kimbro Staken
//  <http://www.xmldatabases.org/WK/blog/1154?t=item>
//

#import "URLCommand.h"
#import "NSString+PECrypt.h"

@interface URLCommand ()

- (id)performWithURL:(NSString *)url;

@end


@implementation URLCommand

- (id)performDefaultImplementation {
	NSString *url = [self directParameter];
	NSLog(@"URL = %@", url);
	return [self performWithURL:url];
}

- (id)performWithURL:(NSString *)url {
	// URL has the following format:
	// com.mycompany.myapp.lic://<base64-encoded-username>/<serial-number>
	NSArray *protocolAndTheRest = [url componentsSeparatedByString:@"://"];
	if ([protocolAndTheRest count] != 2) {
		NSLog(@"License URL is invalid (no protocol)");
		return nil;
	}
	// Separate user name and serial number
	NSArray *userNameAndSerialNumber = [[protocolAndTheRest objectAtIndex:1] componentsSeparatedByString:@"/"];
	if ([userNameAndSerialNumber count] != 2) {
		NSLog(@"License URL is invalid (missing parts)");
		return nil;
	}
	// Decode base64-encoded user name
	NSString *usernameb64 = (NSString *)[userNameAndSerialNumber objectAtIndex:0];
	NSString *username = [usernameb64 base64Decode];
	NSLog(@"User name: %@", username);
	NSString *serial = (NSString *)[userNameAndSerialNumber objectAtIndex:1];
	NSLog(@"Serial: %@", serial);
	// TODO: Save registration to preferences.
	// TODO: Broadcast notification of a changed registration information.
	return nil;
}

@end
