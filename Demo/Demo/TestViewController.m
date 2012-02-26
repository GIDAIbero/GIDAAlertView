//
//  TestViewController.m
//  Demo
//
//  Created by Yoshiki - Vázquez Baeza on 16/02/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

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
        customAlert=[[GIDAAlertView alloc] initWithMessage:@"GIDAAlertView Custom" andAlertImage:[UIImage imageNamed:@"noresource.png"]];
        spinnerAlert=[[GIDAAlertView alloc] initAlertWithSpinnerAndMessage:@"GIDAAlertView Spinner"];
    }
    return self;
}

- (void)dealloc{
    [segmentedSelector release];
    [spinnerAlert release];
}

-(IBAction)showAlert:(id)sender{
    if ([segmentedSelector selectedSegmentIndex] == 0) {
        //Depending on the initialization type, the behavior will be different
        [customAlert presentAlertFor:2];
    }
    else{
        if([spinnerAlert alertIsVisible] == NO){
            [spinnerAlert presentAlertWithSpinner];
        }
        else{
            [spinnerAlert hideAlertWithSpinner];
        }
    }
}

#pragma mark - View lifecycle
- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.segmentedSelector=nil;
}

@end
