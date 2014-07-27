//
//  IPSecondViewController.m
//  Impulse
//
//  Created by Jerome, Samuel on 7/26/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import "IPSecondViewController.h"
#import "AFNetworking.h"
static CGPoint original;

@interface IPSecondViewController ()
@property (nonatomic, retain) IBOutlet UITextField *price;
@property (nonatomic, strong) NSString *oldPrice;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UIButton *selectButton;
@property (nonatomic, retain) IBOutlet UIButton *takePhotoButton;
@end

@implementation IPSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        [self.takePhotoButton setEnabled:NO];
        
    }
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]init];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelToolbarPressed:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Set!" style:UIBarButtonItemStyleDone target:self action:@selector(setToolbarPressed:)],
                           nil];
    [numberToolbar sizeToFit];
    self.price.inputAccessoryView = numberToolbar;
    self.price.delegate = self;
    original = _price.center;
    
    self.imageView.layer.cornerRadius = 10;
    [self.imageView.layer setMasksToBounds:YES];
    
    self.selectButton.layer.cornerRadius =10;
    self.takePhotoButton.layer.cornerRadius = 10;
    self.uploadButton.layer.cornerRadius = 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = [self imageCrop: info[UIImagePickerControllerEditedImage]];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma TextFieldDelegates

-(NSString*) formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}


//This delegate is called everytime a character is inserted in an UITextfield.
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.price) {
        NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSInteger centValue= cleanCentString.integerValue;
        
        if (string.length > 0)
        {
            centValue = centValue * 10 + string.integerValue;
        }
        else
        {
            centValue = centValue / 10;
        }
        
        NSNumber *formatedValue;
        formatedValue = [[NSNumber alloc] initWithFloat:(float)centValue / 100.0f];
        NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        textField.text = [_currencyFormatter stringFromNumber:formatedValue];
        return NO;
    }
    
    //Returning yes allows the entered chars to be processed
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:.3 animations:^{
        textField.center = _imageView.center;
        textField.alpha = .8;
    }];
    [UIView commitAnimations];
    self.oldPrice = textField.text;
    
}

-(IBAction)cancelToolbarPressed:(id)sender {
    [_price resignFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        _price.center = original;
        _price.alpha = 1.0;
    }];
    [UIView commitAnimations];
    self.price.text = _oldPrice;
}

-(IBAction)setToolbarPressed:(id)sender {
    [_price resignFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        _price.center = original;
        _price.alpha = 1.0;
    }];
    [UIView commitAnimations];
}

-(IBAction)didPressSubmit:(id)sender {
    [self.uploadButton setEnabled:NO];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(_uploadButton.frame.size.width/2-25, _uploadButton.frame.size.height/2 - 25, 50, 50)];
    [indicator setColor:[UIColor blackColor]];
    [indicator startAnimating];

    NSString *finalPrice = [[_price.text stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    [self.uploadButton addSubview:indicator];
    
    NSData *data = UIImagePNGRepresentation(_imageView.image);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"price": finalPrice, @"user_id":userID, @"phone_number": kPhoneNumber};
    [manager POST:[NSString stringWithFormat:@"%@%@", serverURL, @"api/v1/posts"] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"image" fileName:@"file" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        
        [self.uploadButton setEnabled:YES];
        [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Uploaded Image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        self.tabBarController.selectedIndex = 0;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.uploadButton setEnabled:YES];
        [indicator removeFromSuperview];
//        NSLog(@"%@", error);
    }];
}

-(UIImage*)imageCrop:(UIImage*)original
{
    UIImage *ret = nil;
    
    // This calculates the crop area.
    
    float originalWidth  = original.size.width;
    float originalHeight = original.size.height;
    
    float edge = fminf(originalWidth, originalHeight);
    
    float posX = (originalWidth   - edge) / 2.0f;
    float posY = (originalHeight  - edge) / 2.0f;
    
    CGRect cropSquare;
    if(original.imageOrientation == UIImageOrientationLeft ||
       original.imageOrientation == UIImageOrientationRight) {
        cropSquare = CGRectMake(posY, posX, edge, edge);
    } else {
        cropSquare = CGRectMake(posX, posY, edge, edge);
    }
    cropSquare = CGRectMake(posY, posX, edge, edge);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([original CGImage], cropSquare);
    
    ret = [UIImage imageWithCGImage:imageRef
                              scale:original.scale
                        orientation:original.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return ret;
}

@end
