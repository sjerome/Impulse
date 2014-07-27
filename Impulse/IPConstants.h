//
//  IPConstants.h
//  Impulse
//
//  Created by Jerome, Samuel on 7/26/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import <Foundation/Foundation.h>
#define serverURL @"http://10.0.0.14:3000/"
#define userID [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]
#define kPhoneNumber [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"]


@interface IPConstants : NSObject

@end
