//
//  GIDAAlertView.h
//
//  Created by Yoshiki Vázquez Baeza on 25/10/11.
//  Copyright (c) 2011 Polar Bears Nanotechnology Research ©. All rights reserved.
//
//  To do:
//      + Support iPhone (landscape)
//      + Support iPad (portrait, landscape) 
//      + Support ARC
//      + Support iOS 4 and lower

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kGIDAAlertViewAnimationDuration 1

typedef enum {
    GIDAAlertViewTypeCustom=0,
    GIDAAlertViewTypeLoading
}GIDAAlertViewType;

@interface GIDAAlertView : UIView{
    float secondsVisible;
    BOOL alertIsVisible;
    
    @private
    UILabel *messageLabel;
    UIImageView *theImageView;
    UIImageView *theBackgroundView;
    
    @protected
    GIDAAlertViewType type;
}

@property (nonatomic, assign) float secondsVisible;
@property (nonatomic, readonly, assign) BOOL alertIsVisible;

@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIImageView *theImageView;
@property (nonatomic, retain) UIImageView *theBackgroundView;

@property (nonatomic, assign) GIDAAlertViewType type;

//**GIDAAlertViewTypeCustom
//Simple alert to present a short message to the user aided with an image (80x80 px)
-(id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage;

//When a alert view has already been created and we want to modify it's contents
-(void)reloadWith:(NSString *)message andImage:(UIImage *)someImage;

//Show the view for "seconds", the view will be added to the last view in the hierarchy
-(void)presentAlertFor:(float)seconds;

//**GIDAAlertViewTypeLoading**
//The common alert known as the "Downloading ..." alert is created with this method, you have
//to manage when the alert is shown and when you hide it
-(id)initAlertWithSpinnerAndMessage:(NSString *)someMessage;

//Show or hide the view, the view will be added to the last view in the hierarchy
-(void)presentAlertWithSpinner;
-(void)hideAlertWithSpinner;


@end
