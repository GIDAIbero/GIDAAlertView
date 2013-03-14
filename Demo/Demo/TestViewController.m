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
        spinnerAlert = nil;
    }
    return self;
}

- (void)dealloc{
    [segmentedSelector release];
    [spinnerAlert release];
    
    [super dealloc];
}
- (void)wasteTimeMethod {
    [NSThread sleepForTimeInterval:10];
}

-(IBAction)showAlert:(id)sender{
    switch ([segmentedSelector selectedSegmentIndex]) {
        case 0:
            customAlert=[[GIDAAlertView alloc] initWithMessage:@"GIDAAlertView Custom" andAlertImage:[UIImage imageNamed:@"noresource.png"]];
            
            [customAlert setColor:[UIColor iberoBlueColor]];
            [customAlert presentAlertFor:2];
            break;
        case 1:
            spinnerAlert = [[GIDAAlertView alloc] initWithSpinnerAndMessage:@"GIDAAlertView Spinner"];
            [spinnerAlert presentAlertWithSpinnerAndHideAfterSelector:@selector(wasteTimeMethod) from:self withObject:nil];
            break;
        case 2:
            customAlert = [[GIDAAlertView alloc] initWithPrompt:@"Test" delegate:nil cancelButtonTitle:@"Cancel" acceptButtonTitle:@"Accept"];
            [customAlert show];
            break;
        case 3:
            customAlert = [[GIDAAlertView alloc] initWithProgressBarAndMessage:@"Downloading" andTime:20];
            [customAlert presentProgressBar];
            break;
            
        default:
            break;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

#pragma mark - View lifecycle
- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.segmentedSelector=nil;
}

@end
