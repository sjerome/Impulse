//
//  IPFirstViewController.m
//  Impulse
//
//  Created by Jerome, Samuel on 7/26/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import "IPFirstViewController.h"
#import "IPImageView.h"
static CGRect oldFrame;
static UIColor *oldColor;

@interface IPFirstViewController () {
    CLLocationCoordinate2D position;
}
-(IBAction)didPressLike:(id)sender;
-(IBAction)didPressDislike:(id)sender;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet IPImageView *imageview1;
@property (nonatomic, retain) IBOutlet IPImageView *imageview2;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UIButton *dislikeButton;
@end

@implementation IPFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    oldFrame = self.imageview1.frame;
    oldColor = _priceLabel.backgroundColor;
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.imageview1 setUserInteractionEnabled:YES];

    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    [recognizer setNumberOfTouchesRequired:1];
    [self.imageview1 addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    [recognizer setNumberOfTouchesRequired:1];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.imageview1 addGestureRecognizer:recognizer];
    
    self.priceLabel.layer.cornerRadius = 10;
    
    self.imageview2.layer.cornerRadius = 10;
    self.imageview1.layer.cornerRadius = 10;
    
    self.buyButton.layer.cornerRadius = 10;
    self.dislikeButton.layer.cornerRadius = 10;

    [self.imageview1.layer setMasksToBounds:YES];
    [self.imageview2.layer setMasksToBounds:YES];
    [self.buyButton.layer setMasksToBounds:YES];
    [self.dislikeButton.layer setMasksToBounds:YES];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPressLike:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase From:" message:_imageview1.phoneNumber delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    [UIView animateWithDuration:.5 animations:^{
        [self.priceLabel setBackgroundColor:[UIColor clearColor]];
        [self.priceLabel setText:@""];
        
        self.imageview1.frame = CGRectMake(self.view.frame.size.width, self.imageview1.frame.origin.y, self.imageview1.frame.size.width, self.imageview1.frame.size.height);
    } completion:^(BOOL finished){
        [self resetViews:@"LIKE"];
    }];
    [UIView commitAnimations];
}

-(IBAction)didPressDislike:(id)sender {
    [UIView animateWithDuration:.5 animations:^{
        [self.priceLabel setBackgroundColor:[UIColor clearColor]];
        [self.priceLabel setText:@""];

        self.imageview1.frame = CGRectMake(-self.imageview1.frame.size.width, self.imageview1.frame.origin.y, self.imageview1.frame.size.width, self.imageview1.frame.size.height);
    } completion:^(BOOL finished){
        [self resetViews:@"DISLIKE"];
    }];
    [UIView commitAnimations];
}
-(IBAction)swipeHandle:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self didPressLike:sender];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft){
        [self didPressDislike:sender];
    } else {
        NSLog(@"Wrong direction bro");
    }
}

-(void)fetchImageFromServer:(NSString *)type postID:(NSString *)postID completionBlock:(void (^)(void)) completion{
    NSURL *url;
    if (!postID || [postID isEqualToString:@"FAKE"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/posts/users/%@", serverURL, userID]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/posts/%@/users/%@/%@", serverURL, postID, userID, type]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.imageview2.postID = dictionary[@"_id"];
                self.imageview2.price = [NSString stringWithFormat:@"$%.2f", [dictionary[@"price"] floatValue]];
                self.imageview2.phoneNumber = dictionary[@"phone_number"];
                self.imageview2.image = [UIImage imageWithData: [[NSData alloc] initWithBase64EncodedString:dictionary[@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters]];
            }
            @catch (NSException *exception) {
                self.imageview2.postID = @"FAKE";
                self.imageview2.price = @"$20.00";
                self.imageview2.phoneNumber = @"917-750-4054";
                self.imageview2.image = [UIImage imageNamed: @"imgres-2.jpg"];
            }
            @finally {
                completion();
            }
        });
    }];
}

-(void)resetViews:(NSString *)type {
    self.imageview1.frame = oldFrame;
    self.imageview1.image = self.imageview2.image;
    self.imageview1.postID = self.imageview2.postID;
    self.imageview1.phoneNumber = self.imageview2.phoneNumber;
    self.priceLabel.text = self.imageview2.price;
    if (self.priceLabel.text && ![self.priceLabel.text isEqualToString:@""]) {
        [self.priceLabel setBackgroundColor:oldColor];
    }
    
    self.imageview2.image = nil;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(_imageview2.frame.size.width/2-25, _imageview2.frame.size.height/2-25, 50,50)];
    [self.imageview2 addSubview:indicator];
    [indicator startAnimating];
    
    [self fetchImageFromServer:@"DISLIKE" postID:self.imageview1.postID completionBlock:^{
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    position = [[locations lastObject] coordinate];
}

@end
