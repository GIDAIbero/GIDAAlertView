//
//  GIDAAlertView.m
//  iBero
//
//  Created by Yoshiki - Vázquez Baeza on 25/10/11.
//  Copyright (c) 2011 Polar Bears Nanotechnology Research ©. All rights reserved.
////

#import "GIDAAlertView.h"

//Private methods of the class
@interface GIDAAlertView (private)

-(void)enterLimbo:(id)sender;
-(void)leaveLimbo:(id)sender;

-(void)addToBottomView:(id)sender;

@end

@implementation GIDAAlertView (private)

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
                         [self removeFromSuperview];
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

-(id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage{
    if(self = [super initWithFrame:CGRectMake(70, 100, 180, 180)]){
        //This allows the user to keep interaction with the screen
        [self setClipsToBounds:YES];
        
        //Customize the vie by making it transparent and round in the corners
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setCornerRadius:20.0];

        //The Label
        messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 110, 170, 60)];
        [messageLabel setText:someMessage];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setTextAlignment:UITextAlignmentCenter];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setFont:[UIFont systemFontOfSize:20]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        
        theImageView=[[UIImageView alloc] initWithImage:someImage];
        [theImageView setFrame:CGRectMake(50, 20, 80, 80)];
        [self addSubview:theImageView];
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        //Should start hidden from the <<eye>>
        alertIsVisible=NO;
  
        //Type custom has a seconds visible class
        type=GIDAAlertViewTypeCustom;
        secondsVisible=0;
    }
    return self;
}

-(id)initAlertWithSpinnerAndMessage:(NSString *)someMessage{
    if(self = [super initWithFrame:CGRectMake(70, 100, 180, 180)]){
        //This allows the user to keep interaction with the screen
        [self setClipsToBounds:YES];
        
        //Customize the vie by making it transparent and round in the corners
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setCornerRadius:20.0];
        
        //The label
        messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 110, 170, 60)];
        [messageLabel setText:someMessage];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setTextAlignment:UITextAlignmentCenter];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setFont:[UIFont systemFontOfSize:20]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        
        //This GIDAAlertViewType has a spinner
        UIActivityIndicatorView *theSpinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [theSpinner setFrame:CGRectMake(50, 20, 80, 80)];
        [theSpinner startAnimating];
        [self addSubview:theSpinner];
        [theSpinner release];
        
        //It always start hidden from the <<eye>> 
        alertIsVisible=NO;
        
        //Set the type
        type=GIDAAlertViewTypeLoading;
        
        secondsVisible=0;
    }
    return self;
}


-(void)reloadWith:(NSString *)message andImage:(UIImage *)someImage{
    if (type == GIDAAlertViewTypeCustom) {
        [messageLabel setText:message];
        [theImageView setImage:someImage];
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
                             [self removeFromSuperview];
                         }
         ];
        
        alertIsVisible=NO;
    }
    else if (type == GIDAAlertViewTypeCustom){
        NSLog(@"GIDAAlertView**:Can't call hideAlertWithSpinner on GIDAAlertViewTypeCustom");
    }
}

-(void)dealloc{
    //[theBackgroundView release];
    [messageLabel release];
    
    if (type == GIDAAlertViewTypeCustom) {
        [theImageView release];
    }
    
    [super dealloc];
}
@end