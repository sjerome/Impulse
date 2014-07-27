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

@interface IPFirstViewController ()
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
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.imageview1 setUserInteractionEnabled:YES];

    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    [recognizer setNumberOfTouchesRequired:1];
    [self.imageview1 addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
    [recognizer setNumberOfTouchesRequired:1];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.imageview1 addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPressLike:(id)sender {
    [UIView animateWithDuration:.5 animations:^{
        self.imageview1.frame = CGRectMake(self.view.frame.size.width, self.imageview1.frame.origin.y, self.imageview1.frame.size.width, self.imageview1.frame.size.height);
    } completion:^(BOOL finished){
        [self resetViews];
    }];
    [UIView commitAnimations];
}

-(IBAction)didPressDislike:(id)sender {
    [UIView animateWithDuration:.5 animations:^{
        self.imageview1.frame = CGRectMake(-self.imageview1.frame.size.width, self.imageview1.frame.origin.y, self.imageview1.frame.size.width, self.imageview1.frame.size.height);
    } completion:^(BOOL finished){
        [self resetViews];
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

-(UIImage *)fetchImageFromServer:(NSString *)type postID:(NSString *)postID{
    NSURL *url;
    if (!postID) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/posts/users/%@", serverURL, @"53d4b85225971fc413000004"]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/posts/%@/users/%@/%@", serverURL, postID, @"53d4b85225971fc413000004", type]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *res;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
    UIImage *image = nil;
    @try {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:nil];
        self.imageview2.postID = dictionary[@"_id"];
        self.imageview2.price = [NSString stringWithFormat:@"$%.2f", [dictionary[@"price"] floatValue]] ;
        image = [UIImage imageWithData: [[NSData alloc] initWithBase64EncodedString:dictionary[@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        return image;
    }

}

-(void)resetViews {
    self.imageview1.frame = oldFrame;
    self.imageview1.image = self.imageview2.image;
    self.imageview1.postID = self.imageview2.postID;
    self.priceLabel.text = self.imageview2.price;
    
    self.imageview2.image = [self fetchImageFromServer:@"DISLIKE" postID:self.imageview1.postID];
}

@end
