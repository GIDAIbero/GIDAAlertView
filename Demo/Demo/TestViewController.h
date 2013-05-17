//
//  TestViewController.h
//  Demo
//
//  Created by Yoshiki - Vázquez Baeza on 16/02/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIDAAlertView.h"

@interface TestViewController : UIViewController <GIDAAlertViewDelegate> {
    UISegmentedControl *segmentedSelector;
    
    @private
    GIDAAlertView *spinnerAlert;
    GIDAAlertView *customAlert;
}

@property (strong, readwrite) IBOutlet UISegmentedControl *segmentedSelector;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedSecond;
@property (strong, readwrite) GIDAAlertView *spinnerAlert;
@property (strong, readwrite) GIDAAlertView *customAlert;


-(IBAction)showAlert:(id)sender;
@end
