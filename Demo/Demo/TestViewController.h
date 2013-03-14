//
//  TestViewController.h
//  Demo
//
//  Created by Yoshiki - Vázquez Baeza on 16/02/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIDAAlertView.h"

@interface TestViewController : UIViewController{
    UISegmentedControl *segmentedSelector;
    
    @private
    GIDAAlertView *spinnerAlert;
    GIDAAlertView *customAlert;
}

@property (retain, readwrite) IBOutlet UISegmentedControl *segmentedSelector;
@property (retain, readwrite) GIDAAlertView *spinnerAlert;
@property (retain, readwrite) GIDAAlertView *customAlert;


-(IBAction)showAlert:(id)sender;
@end
