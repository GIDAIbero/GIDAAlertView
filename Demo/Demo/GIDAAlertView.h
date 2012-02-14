//
//  GIDAAlertView.h
//  iBero
//
//  Created by Yoshiki Vázquez Baeza on 25/10/11.
//  Copyright (c) 2011 Polar Bears Nanotechnology Research ©. All rights reserved.
//
//
#import <UIKit/UIKit.h>

typedef enum {
    GIDAAlertViewTypeCustom=0,
    GIDAAlertViewTypeLoading
}GIDAAlertViewType;

@interface GIDAAlertView : UIView{
    float secondsVisible;
    
    @private
    UILabel *messageLabel;
    UIImageView *theImageView;
    UIImageView *theBackgroundView;
    
    @protected
    GIDAAlertViewType type;
}

@property (nonatomic, assign) float secondsVisible;

@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIImageView *theImageView;
@property (nonatomic, retain) UIImageView *theBackgroundView;

@property (nonatomic, assign) GIDAAlertViewType type;

//Generic constructor
-(id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage;

//The common alert known as the "Downloading ..." dialog is created with this method
//you have to know when to hide it and to remove it from the superview
-(id)initAlertWithSpinnerAndMessage:(NSString *)someMessage;

//When a alert view has already been created and we want to modify it's contents use this method
-(void)reloadWith:(NSString *)message andImage:(UIImage *)someImage;

//Show or hide the view
-(void)presentAlertFor:(float)seconds;

//Appear and dissapear
-(void)enterLimbo:(id)sender;
-(void)leaveLimbo:(id)sender;

//Spinner Methods
-(void)presentAlertWithSpinner;
-(void)hideAlertWithSpinner;

@end
