//
//  CFobError.h
//  cocoafob
//
//  Created by Danny Greg on 24/08/2010.
//  Copyright 2010 Realmac Software. All rights reserved.
//  Licensed under CC Attribution Licence 3.0 <http://creativecommons.org/licenses/by/3.0/>
//

#import "CFobError.h"

#import "CFobLicVerifier.h"

void CFobAssignErrorWithDescriptionAndCode(NSError **err, NSString *description, NSInteger code)
{
	if (err != NULL)
		*err = [NSError errorWithDomain:[[NSBundle bundleForClass:[CFobLicVerifier class]] bundleIdentifier] code:code userInfo:[NSDictionary dictionaryWithObject:NSLocalizedStringFromTableInBundle(description, nil, [NSBundle bundleForClass:[CFobLicVerifier class]], nil) forKey:NSLocalizedDescriptionKey]];
}
