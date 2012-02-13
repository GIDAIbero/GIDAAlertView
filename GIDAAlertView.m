//
//  GIDAAlertView.m
//  iBero
//
//  Created by Yoshiki - Vázquez Baeza on 25/10/11.
//  Copyright (c) 2011 Polar Bears Nanotechnology Research ©. All rights reserved.
////

#import "GIDAAlertView.h"

@implementation GIDAAlertView

@synthesize secondsVisible;
@synthesize messageLabel, theImageView, theBackgroundView;
@synthesize type;

-(id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage{
    if(self = [super initWithFrame:CGRectMake(70, 100, 180, 180)]){
        
        //Be able to see anything behind the view
        [self setBackgroundColor:[UIColor clearColor]];
        
        //Images
        theBackgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alertBackground.png"]];
        [theBackgroundView setFrame:CGRectMake(0, 0, 180, 180)];
        [self addSubview:theBackgroundView];
        
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
        
        [self setHidden:YES];
        
        type=GIDAAlertViewTypeCustom;
        
        secondsVisible=0;
    }
    return self;
}

-(id)initAlertWithSpinnerAndMessage:(NSString *)someMessage{
    if(self = [super initWithFrame:CGRectMake(0, 0, 320, 414)]){
        
        //Be able to see anything behind the view
        [self setBackgroundColor:[UIColor clearColor]];
        UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(70,100,180,180)];
        //Images
        theBackgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alertBackground.png"]];
        [theBackgroundView setFrame:CGRectMake(0, 0, 180, 180)];
        [theView addSubview:theBackgroundView];
        
        messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 110, 170, 60)];
        [messageLabel setText:someMessage];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setTextAlignment:UITextAlignmentCenter];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setFont:[UIFont systemFontOfSize:20]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [theView addSubview:messageLabel];
        
        UIActivityIndicatorView *theSpinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [theSpinner setFrame:CGRectMake(50, 20, 80, 80)];
        [theSpinner startAnimating];
        [theView addSubview:theSpinner];
        [theSpinner release];
        
        [self setHidden:NO];
        
        type=GIDAAlertViewTypeLoading;
        
        secondsVisible=0;
        [self addSubview:theView];
        [theView release];
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
    [self setSecondsVisible:seconds];
    [self setHidden:NO];
    
    //We are going to be waiting for a time interval, so in order to avoid blocking the main thread
    //perform the waiting in another thread
    [NSThread detachNewThreadSelector:@selector(enterLimbo:) toTarget:self withObject:nil];
}

-(void)presentAlertWithSpinner {
    [self setHidden:NO];
}

-(void)hideAlertWithSpinner {
    [self setHidden:YES];
}

-(void)enterLimbo:(id)sender{
    [NSThread sleepForTimeInterval:secondsVisible];
    [self performSelectorOnMainThread:@selector(leaveLimbo:) withObject:nil waitUntilDone:YES];
}
-(void)leaveLimbo:(id)sender{
    [self setHidden:YES];
}

-(void)dealloc{
    [theBackgroundView release];
    [messageLabel release];
    
    if (type == GIDAAlertViewTypeCustom) {
        [theImageView release];
    }
    
    [super dealloc];
}

@end
