//
//  IPSecondViewController.h
//  Impulse
//
//  Created by Jerome, Samuel on 7/26/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPSecondViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)selectPhoto:(UIButton *)sender;
@end
