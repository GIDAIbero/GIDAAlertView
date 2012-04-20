//
//  GIDAAlertView.m
//  iBero
//
//  Created by Yoshiki - Vázquez Baeza on 25/10/11.
//  Copyright (c) 2011 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#import "GIDAAlertView.h"

CGRect const kiPhonePortraitRect={{.x=70, .y=100}, {.width=180, .height=180}};
CGRect const kiPhoneLandscapeRect={{.x=150, .y=30}, {.width=180, .height=180}};
CGRect const kiPadPortraitRect={{.x=294, .y=300}, {.width=180, .height=180}};
CGRect const kiPadLandscapeRect={{.x=422, .y=144}, {.width=180, .height=180}};

//Private methods of the class 1024x768
@interface GIDAAlertView (private)

//Determine the rect used for the position of the view
+(CGRect)rectForInterfaceOrientation:(UIInterfaceOrientation)theInterfaceOrientation;

-(void)enterLimbo:(id)sender;
-(void)leaveLimbo:(id)sender;

-(void)addToBottomView:(id)sender;

@end

@implementation GIDAAlertView (private)

+(CGRect)rectForInterfaceOrientation:(UIInterfaceOrientation)theInterfaceOrientation{
    
    //Choose between a phone/pod or pad then return the appropiate constant
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if (theInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || theInterfaceOrientation == UIInterfaceOrientationPortrait) {
            return kiPhonePortraitRect;
        }
        else {
            return kiPhoneLandscapeRect;
        }
    }
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        
        if (theInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || theInterfaceOrientation == UIInterfaceOrientationPortrait) {
            return kiPadPortraitRect;
        }
        else {
            return kiPadLandscapeRect;
        }
    }
    
    //Default safe return value
    return CGRectZero;
}

-(void)enterLimbo:(id)sender{
    [NSThread sleepForTimeInterval:secondsVisible];
    [self performSelectorOnMainThread:@selector(leaveLimbo:) withObject:nil waitUntilDone:YES];
}

-(void)leaveLimbo:(id)sender{
    //Remove the view     
    [UIView animateWithDuration:kGIDAAlertViewAnimationDuration animations:^{
                        [self setAlpha:0.0];
                    }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }
     ];
    
    //Update the ivars
    alertIsVisible=NO;
}

-(void)addToBottomView:(id)sender{
    //Get the view that is down at the bottom
    NSArray *arrayOfViews=[NSArray arrayWithArray:[[[UIApplication sharedApplication] keyWindow] subviews]];    
    UIView *lastView=[arrayOfViews objectAtIndex:[arrayOfViews count]-1];
    //Add the alert
    [lastView addSubview:self];
}

@end

@implementation GIDAAlertView

@synthesize secondsVisible, alertIsVisible;
@synthesize messageLabel, theImageView, theBackgroundView;
@synthesize type;

-(id)init{
    if (self = [super initWithFrame:[GIDAAlertView rectForInterfaceOrientation:UIInterfaceOrientationPortrait]]) {
        //This allows the user to keep interaction with the screen
        [self setClipsToBounds:YES];
        
        //Customize the vie by making it transparent and round in the corners
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setCornerRadius:20.0];
        
        //It always start hidden from the <<eye>> 
        alertIsVisible=NO;        
        secondsVisible=0;

        //The Label
        messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 110, 180, 60)];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setTextAlignment:UITextAlignmentCenter];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [messageLabel setShadowColor:[UIColor grayColor]];
        [messageLabel setShadowOffset:CGSizeMake(1, 0.78)];
        [messageLabel setNumberOfLines:0];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        
        //Listen to the notification center
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToInterfaceOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:[UIDevice currentDevice]];
    }
    return self;
}

-(id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage{
    if(self = [self init]){
        [messageLabel setText:someMessage];
        
        //Main icon of the alert view
        theImageView=[[UIImageView alloc] initWithImage:someImage];
        [theImageView setFrame:CGRectMake(50, 20, 80, 80)];
        [self addSubview:theImageView];
        [self setContentMode:UIViewContentModeScaleAspectFit];
  
        //Type custom has a seconds visible class
        type=GIDAAlertViewTypeCustom;
    }
    return self;
}

-(id)initAlertWithSpinnerAndMessage:(NSString *)someMessage{
    if(self = [self init]){
        [messageLabel setText:someMessage];
        
        //This GIDAAlertViewType has a spinner
        UIActivityIndicatorView *theSpinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [theSpinner setFrame:CGRectMake(50, 20, 80, 80)];
        [theSpinner startAnimating];
        [self addSubview:theSpinner];
        [theSpinner release];
        
        //Set the type
        type=GIDAAlertViewTypeLoading;
    }
    return self;
}

-(void)reloadWith:(NSString *)message andImage:(UIImage *)someImage{
    if (type == GIDAAlertViewTypeCustom) {
        [messageLabel setText:message];
        [theImageView setImage:someImage];
    }
    else {
        NSLog(@"GIDAAlertView**:Can't call reloadWith:(NSString *)message andImage:(UIImage *)someImage on GIDAAlertViewTypeLoading");
    }
}

-(void)presentAlertFor:(float)seconds{
    //Prevent from calling this method on a different GIDAAlertViewType
    if (type == GIDAAlertViewTypeCustom && alertIsVisible == NO) {
        [self addToBottomView:nil];
        
        //Update the ivars
        [self setSecondsVisible:seconds];
        [self setAlpha:1];
        alertIsVisible=YES;
        
        //We are going to be waiting for a time interval, so in order to avoid blocking the main thread
        //perform the waiting in another thread
        [NSThread detachNewThreadSelector:@selector(enterLimbo:) toTarget:self withObject:nil];
    }
    else if (type == GIDAAlertViewTypeLoading){
        NSLog(@"GIDAAlertView**:Can't call presentAlertFor:(float)seconds on GIDAAlertViewTypeLoading");
    }
}

-(void)presentAlertWithSpinner {
    //Prevent from calling this method on a different GIDAAlertViewType
    if (type == GIDAAlertViewTypeLoading && alertIsVisible == NO) {
        [self addToBottomView:nil];    
        [self setAlpha:1];
        alertIsVisible=YES;
    }
    else if (type == GIDAAlertViewTypeCustom){
        NSLog(@"GIDAAlertView**:Can't call presentAlertWithSpinners on GIDAAlertViewTypeCustom");
    }
}

-(void)hideAlertWithSpinner {
    //Prevent from calling this method on a different GIDAAlertViewType
    if (type == GIDAAlertViewTypeLoading && alertIsVisible == YES) {
        //Hide the view using the alpha
        [UIView animateWithDuration:kGIDAAlertViewAnimationDuration animations:^{
                            [self setAlpha:0.0];
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [self removeFromSuperview];
                             }                             
                         }
         ];
        
        //Update the ivars
        alertIsVisible=NO;
    }
    else if (type == GIDAAlertViewTypeCustom){
        NSLog(@"GIDAAlertView**:Can't call hideAlertWithSpinner on GIDAAlertViewTypeCustom");
    }
}

-(void)updateToInterfaceOrientation{
    UIInterfaceOrientation toInterfaceOrientation=[[UIDevice currentDevice] orientation];
    
    //Landscape
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self setFrame:[GIDAAlertView rectForInterfaceOrientation:toInterfaceOrientation]];
    }
    
    //Portrait
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
        [self setFrame:[GIDAAlertView rectForInterfaceOrientation:toInterfaceOrientation]];
    }
    
}

-(void)dealloc{
    [messageLabel release];
    
    //This property is only allocated when the type is custom
    if (type == GIDAAlertViewTypeCustom) {
        [theImageView release];
    }
    
    [super dealloc];
}
@end
