//
//  IPFirstViewController.h
//  Impulse
//
//  Created by Jerome, Samuel on 7/26/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface IPFirstViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@end
