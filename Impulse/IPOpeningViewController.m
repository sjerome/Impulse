//
//  IPOpeningViewController.m
//  Impulse
//
//  Created by Jerome, Samuel on 7/26/14.
//  Copyright (c) 2014 Binder. All rights reserved.
//

#import "IPOpeningViewController.h"

@interface IPOpeningViewController ()
@property (nonatomic, retain) IBOutlet UIButton *fbLogin;
@property (nonatomic, retain) IBOutlet UITextField *phoneNumber;
@end

@implementation IPOpeningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneNumber.delegate = self;
    UIToolbar* numberToolbar = [[UIToolbar alloc]init];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelToolbarPressed:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(cancelToolbarPressed:)],
                           nil];
    [numberToolbar sizeToFit];
    self.phoneNumber.inputAccessoryView = numberToolbar;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    self.phoneNumber.text = [self formatPhoneNumber:[NSString stringWithFormat:@"%@%@",_phoneNumber.text, string]  deleteLastChar:NO];
    return NO;
    
}

-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    // check if the number is to long
    if(simpleNumber.length>10) {
        // remove last extra chars.
        simpleNumber = [simpleNumber substringToIndex:10];
    }
    
    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else   // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}

-(IBAction)cancelToolbarPressed:(id)sender {
    [_phoneNumber resignFirstResponder];
}

-(IBAction)donePressed:(id)sender {
    if (_phoneNumber.text.length < 14) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Number improper" delegate:nil cancelButtonTitle:@"OK, I'll Fix It" otherButtonTitles:nil] show];
        return;
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/users/auth", serverURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *bodyString = [NSString stringWithFormat:@"phone_number=%@", _phoneNumber.text];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *res;
    NSError *err;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    @try {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:dict[@"_id"] forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] setObject:dict[@"phone_number"] forKey:@"phoneNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"loginSegue" sender:sender];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }
    
}

@end
