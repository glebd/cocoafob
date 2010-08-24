//
//  CFobError.h
//  cocoafob
//
//  Created by Danny Greg on 24/08/2010.
//  Copyright 2010 Realmac Software. All rights reserved.
//  Licensed under CC Attribution Licence 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import <Foundation/Foundation.h>

enum _CFobErrorCode {
	CFobErrorCodeInvalidKey = -1,
	CFobErrorCodeCouldNotDecode = -2,
	CFobErrorCodeSigningFailed = -3,
	CFobErrorCodeCouldNotEncode = -4,
	CFobErrorCodeNoName = -5,
};

void CFobAssignErrorWithDescriptionAndCode(NSError **err, NSString *description, NSInteger code);
