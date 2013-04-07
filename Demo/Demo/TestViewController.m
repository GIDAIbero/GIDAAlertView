//
//  TestViewController.m
//  Demo
//
//  Created by Yoshiki - Vázquez Baeza on 16/02/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#define iberoRedColor       colorWithRed:0.541176 green:0.0745098 blue:0.088274 alpha:1
#define iberoBlueColor      colorWithRed:0.196078 green:0.309803 blue:0.521568 alpha:1

#define bananaColor         colorWithRed:1.0000 green:1.0000 blue:0.4000 alpha:1
#define tangerineColor      colorWithRed:1.0000 green:0.5020 blue:0.0000 alpha:1
#define clearPurpleColor    colorWithRed:0.7401 green:0.7508 blue:1.0000 alpha:1

#define gidaBloodColor      colorWithRed:0.6667 green:0.1000 blue:0.3000 alpha:1
#define gidaPistachioColor  colorWithRed:0.6000 green:1.0000 blue:0.4000 alpha:1
#define gidaYellowColor     colorWithRed:1.0000 green:1.0000 blue:0.6000 alpha:1
#define gidaOrangeColor     colorWithRed:1.0000 green:0.4000 blue:0.2000 alpha:1
#define gidaBlueColor       colorWithRed:0.0000 green:0.4000 blue:1.0000 alpha:1
#define gidaGreenColor      colorWithRed:0.2000 green:0.8000 blue:0.4000 alpha:1
#define gidaRedColor        colorWithRed:1.0000 green:0.5100 blue:0.4000 alpha:1
#define gidaAColor          colorWithRed:0.4000 green:0.4000 blue:1.0000 alpha:1
#define gidaMYellowColor    colorWithRed:1.0000 green:0.8000 blue:0.4000 alpha:1
#define gidaDarkPurpleColor colorWithRed:0.6000 green:0.2000 blue:0.8000 alpha:1
#define gidaGrayColor       colorWithRed:0.7333 green:0.7333 blue:0.7333 alpha:1
#define gidaPinkColor       colorWithRed:1.0000 green:0.2000 blue:0.6000 alpha:1

#import "TestViewController.h"

@implementation TestViewController

@synthesize segmentedSelector;
@synthesize spinnerAlert;
@synthesize customAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization, one of each type
        customAlert  = nil;
    }
    return self;
}

- (void)dealloc{
    [segmentedSelector release];
    
    if (customAlert) {
        [customAlert release];
    }
    
    [_segmentedSecond release];
    [super dealloc];
}
- (void)wasteTimeMethod {
    [NSThread sleepForTimeInterval:5];
}

-(void)alertFinished:(GIDAAlertView *)alertView {
    switch([alertView type]){
        case GIDAAlertViewProgressURL:
            NSLog(@"ProgressURL");
            NSDictionary *data = [alertView getDownloadedData];
            if (data) {
                if (data[@"error"]) {
                    customAlert = [[GIDAAlertView alloc] initWithMessage:data[@"error"]
                                                           andAlertImage:[UIImage imageNamed:@"noresource.png"]];
                    [customAlert presentAlertFor:2];
                    [customAlert release];
                } else {
                    UIWebView *web = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
                    [web loadData:[data objectForKey:@"data"]
                         MIMEType:[data objectForKey:@"mime"]
                 textEncodingName:[data objectForKey:@"encoding"]
                          baseURL:[data objectForKey:@"url"]];
                    UIViewController *uvc = [[UIViewController alloc] init];
                    [uvc.view addSubview:web];
                    UILabel *_cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
                    [_cancelLabel setBackgroundColor:[UIColor blackColor]];
                    [_cancelLabel setTextAlignment:UITextAlignmentCenter];
                    [_cancelLabel setTextColor:[UIColor whiteColor]];
                    [_cancelLabel setText:@"\u2718"];
                    [_cancelLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
                    _cancelLabel.layer.cornerRadius = 15;
                    _cancelLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
                    _cancelLabel.layer.borderWidth = 1.5;
                    CGRect frame = [[UIScreen mainScreen] applicationFrame];
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-35, 0, 20, 20)];
                    [button addSubview:_cancelLabel];
                    [button addTarget:self action:@selector(doneWithWebView:) forControlEvents:UIControlEventTouchUpInside];
                    [uvc.view addSubview:button];
                    [uvc.view bringSubviewToFront:button];
                    [self presentModalViewController:uvc animated:YES];
                    [_cancelLabel release];
                    [web release];
                    [uvc release];
                }
            } else {
                customAlert = [[GIDAAlertView alloc] initWithMessage:@"Connection failed"
                                                       andAlertImage:[UIImage imageNamed:@"noresource.png"]];
                [customAlert presentAlertFor:2];
                [customAlert release];
            }
            break;
        case GIDAAlertViewPrompt:
            if ([alertView accepted]) {
                customAlert = [[GIDAAlertView alloc] initWithTitle:@"Entered text" cancelButtonTitle:nil acceptButtonTitle:@"Ok" andMessage:[alertView enteredText]];
                [customAlert show];
                [customAlert release];
            }
            break;
        default:
            break;
    }
}
-(void)doneWithWebView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
-(void)viewDidLoad {
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:UITextAttributeFont];
        [segmentedSelector setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
        [_segmentedSecond setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
    }
}

-(IBAction)showAlert:(UISegmentedControl *)sender{
    NSURL *url = nil;
    if ([sender isEqual:segmentedSelector]) {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            customAlert=[[GIDAAlertView alloc] initWithMessage:@"GIDAAlertView Custom" andAlertImage:[UIImage imageNamed:@"noresource.png"]];
            [customAlert setColor:[UIColor iberoBlueColor]];
            [customAlert presentAlertFor:2];
            break;
        case 1:
            customAlert = [[GIDAAlertView alloc] initWithPrompt:@"Testing\nTesting"
                                              cancelButtonTitle:@"Cancel"
                                              acceptButtonTitle:@"Accept"];
            [customAlert setDelegate:self];
            [customAlert setColor:[UIColor iberoBlueColor]];
            [customAlert show];
            break;
        case 2:
            customAlert = [[GIDAAlertView alloc] initWithCheckMarkAndMessage:@"Success"];
            [customAlert presentAlertFor:1.08];
            break;
        case 3:
            customAlert = [[GIDAAlertView alloc] initWithXMarkAndMessage:@"No Success"];
            [customAlert presentAlertFor:1.08];
            break;
        case 4:
            customAlert = [[GIDAAlertView alloc] initWithExclamationMarkAndMessage:@"HELP"];
            [customAlert presentAlertFor:1.08];
            break;
        default:
            break;
    }
    } else {
        switch ([sender selectedSegmentIndex]) {
            case 0:
                url = [NSURL URLWithString:@"http://funtooo.com/wp-content/uploads/2013/02/I-m-Hungry...I-Should-Eat-myself.....gif"];
                customAlert = [[GIDAAlertView alloc] initWithProgressBarAndMessage:@"Downloading"
                                                                            andURL:url
                                                               andProgressBarColor:[UIColor iberoRedColor]];
                [customAlert setDelegate:self];
                [customAlert progresBarStartDownload];
                break;
            case 1:
                customAlert = [[GIDAAlertView alloc] initWithProgressBarAndMessage:@"Waiting" andTime:10];
                [customAlert setProgressBarColor:[UIColor gidaOrangeColor]];
                [customAlert presentProgressBar];
                break;
            case 2:
                customAlert = [[GIDAAlertView alloc] initWithSpinnerAndMessage:@"GIDAAlertView Spinner"];
                [customAlert setColor:[UIColor iberoBlueColor]];
                [customAlert presentAlertWithSpinnerAndHideAfterSelector:@selector(wasteTimeMethod) from:self withObject:nil];
                break;
            default:
                break;
        }
    }
    [customAlert release];
    customAlert = nil;
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

#pragma mark - View lifecycle
- (void)viewDidUnload{
    [super viewDidUnload];
    self.segmentedSelector = nil;
    self.segmentedSecond = nil;
    
}

@end
