//
//  GIDASearchAlert.m 2011/10/28 to 2013/02/27
//  GIDAAlertView.m since 2013/02/27
//  TestAlert
//
//  Created by Alejandro Paredes on 10/28/11.
//
// Following methods are inspired in Yoshiki Vázquez Baeza work on previous versions
// of GIDAAlertView.
// - (id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage;
// - (id) initWithSpinnerAndMessage:(NSString *)message;
// - (void)presentAlertFor:(float)seconds;
// - (void)presentAlertWithSpinnerAndHideAfterSelector:(SEL)selector from:(id)sender;
//

#import "GIDAAlertView.h"

@interface LoadingCircle : UIView {
    //Angle for arc, in radians.
    CGFloat angle;
}

//Color for arc
@property (nonatomic, strong) UIColor *arcColor;
@property (nonatomic, strong) UILabel *percentageLabel;
@end

@implementation LoadingCircle
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        //Start at -90 as 0.0 is to the right.
        angle = -90.0f*M_PI/180.0f;
        
        CGRect labelFrame = frame;
        labelFrame.origin.x = 0;
        labelFrame.origin.y = 0;
        //Label to show the current percentage. Size of the frame to have the text centered.
        _percentageLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [_percentageLabel setTextAlignment:NSTextAlignmentCenter];
        [_percentageLabel setBackgroundColor:[UIColor clearColor]];
        [_percentageLabel setTextColor:[UIColor whiteColor]];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [_percentageLabel setFont:[UIFont boldSystemFontOfSize:20]];
        } else {
            [_percentageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        }
        [self addSubview:_percentageLabel];
        _arcColor = [UIColor whiteColor];
    }
    return self;
}
-(void)setProgressLabelColor:(UIColor *)progressLabelColor {
    [_percentageLabel setTextColor:progressLabelColor];
}
-(void)setProgressColor:(UIColor *)color {
    _arcColor = color;
}
//Update percentage values.
-(void)updateProgress:(CGFloat)percentage {
    
    //Update the percentage label appropriately
    if (percentage >= 1.0f) {
        [_percentageLabel setText:@"100%"];
    } else {
        [_percentageLabel setText:[NSString stringWithFormat:@"%.1f%c",percentage*100,'%']];
    }
    
    //Calculate angle from percentage.
    angle = (percentage * 360)-90;
    angle = angle*M_PI/180.0f;
    
    //Call drawRect to draw again.
    [self setNeedsDisplay];
}
//Draw back circle and percentage arc.
-(void)drawRect:(CGRect)rect {
    CGSize size = rect.size;
    CGFloat radius = size.width/2.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 12.0);
    
    //Set the back circle, done by an elipse of the size of the UIView frame.
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGRect elipse = CGRectMake(6, 6, size.width-12, size.height-12);
    CGContextAddEllipseInRect(context, elipse);
    CGContextStrokePath(context);
    
    //Set the arc of the progress so far. Starting from center top, to the percentage angle in a clockwise way.
    CGContextSetStrokeColorWithColor(context, _arcColor.CGColor);
    CGContextAddArc(context, radius, radius, radius-6, -90.0f*M_PI/180.0f, angle, 0);
    CGContextStrokePath(context);
}
@end

@interface ProgressBar : UIView
@property (nonatomic, strong) UIColor *progressColor;
@property CGFloat progress;
@property (nonatomic, strong) UILabel *progressLabel;
@end
@implementation ProgressBar

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.0;
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGRect labelFrame = frame;
        labelFrame.origin.x = 0;
        labelFrame.origin.y = 0;
        _progressLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
        _progressLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [_progressLabel setFont:[UIFont boldSystemFontOfSize:20]];
        } else {
            [_progressLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        }
        [self addSubview:_progressLabel];
    }
    return self;
}
-(void)setProgressLabelColor:(UIColor *)progressLabelColor {
    [_progressLabel setTextColor:progressLabelColor];
}
-(void)setProgressColor:(UIColor *)color {
    _progressColor = color;
}


//Update the percentage value and label appropriately. Call for drawRect again.
-(void)updateProgress:(CGFloat)percentage {
    _progress = percentage;
    
    if (percentage >= 1.0f) {
        [_progressLabel setText:@"100%"];
    } else {
        [_progressLabel setText:[NSString stringWithFormat:@"%.1f%c",fabsf(percentage*100),'%']];
    }
    
    [self setNeedsDisplay];
}

//Create rectangle with rounded corner for the appropiate width related to the progress.
-(void)drawRect:(CGRect)rect {
    rect.size.width = rect.size.width*_progress;
    if (!_progressColor) {
        _progressColor = [UIColor blueColor];
    }
    CGFloat radius = 8;
    if (rect.size.width < 21) {
        radius = rect.size.width/3;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _progressColor.CGColor);
    CGContextSetAlpha(context, 0.8);
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                    rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                    -M_PI / 2, M_PI, 1);
    
    CGContextFillPath(context);
}

@end

@interface GIDAAlertView() {
    BOOL withSpinnerOrImage;
    float progress;
    double timeSeconds;
    float _receivedDataBytes;
    float _totalFileSize;
    GIDAAlertViewType alertType;
    BOOL acceptedAlert;
    BOOL failedDownload;
}

@property (nonatomic, strong) NSString        *entered;
@property (nonatomic, strong) UITextField     *textField;
@property (nonatomic, strong) UILabel         *messageLabel;
@property (nonatomic, strong) UILabel         *messageExtraLabel;
@property (nonatomic, strong) UIColor         *alertColor;
@property (nonatomic, strong) NSTimer         *timer;
@property (nonatomic, strong) NSMutableData   *responseData;
@property (nonatomic, strong) NSURL           *userURL;
@property (nonatomic, strong) NSString        *mimeType;
@property (nonatomic, strong) NSString        *textEncoding;
@property (nonatomic, strong) id               progressBar;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSString        *downloadError;
@property (nonatomic, strong) UILabel         *cancelLabel;
@property (nonatomic, strong) UIView          *backgroundView;
@property (nonatomic, strong) UIImageView     *imageView;
@property (nonatomic, strong) UILabel         *labelMark;
@end

@implementation GIDAAlertView

-(GIDAAlertViewType)type {
    return alertType;
}

-(id)initWithMessage:(NSString *)message andAlertImage:(UIImage *)image {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        withSpinnerOrImage = YES;
        _responseData = nil;
        alertType = GIDAAlertViewMessageImage;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [super setTitle:@""];
            
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 130)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setFrame:CGRectMake(40, 5, 80, 80)];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, 160, 50)];
            [messageLabel setTextAlignment:NSTextAlignmentCenter];
            [messageLabel setText:message];
            [messageLabel setBackgroundColor:[UIColor clearColor]];
            [messageLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [messageLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [messageLabel setAdjustsFontSizeToFitWidth:YES];
            [messageLabel removeFromSuperview];
            
            [_backgroundView addSubview:imageView];
            [_backgroundView addSubview:messageLabel];
            
            [self setValue:_backgroundView forKey:@"accessoryView"];
        } else {
            _backgroundView = nil;
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setFrame:CGRectMake(100, 25, 80, 80)];
            [self addSubview:imageView];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
            [messageLabel setTextAlignment:NSTextAlignmentCenter];
            [messageLabel setText:message];
            [messageLabel setBackgroundColor:[UIColor clearColor]];
            [messageLabel setTextColor:[UIColor whiteColor]];
            [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:messageLabel];
            
            [self bringSubviewToFront:_backgroundView];
            [self bringSubviewToFront:imageView];
            [self bringSubviewToFront:messageLabel];
        }
    }
    return  self;
}

-(id)initWithProgressBarWith:(NSString *)message andTime:(NSInteger)seconds {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        progress = -0.1;
        timeSeconds = seconds/10;
        withSpinnerOrImage = YES;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            self = [super initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(50, 5, 100, 100)];
            [_progressBar setProgressLabelColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 160)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            _messageExtraLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 160, 50)];
            [_messageExtraLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageExtraLabel setText:message];
            [_messageExtraLabel setBackgroundColor:[UIColor clearColor]];
            [_messageExtraLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [_messageExtraLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [_messageExtraLabel setAdjustsFontSizeToFitWidth:YES];
            [_messageExtraLabel removeFromSuperview];
            
            [_backgroundView addSubview:_progressBar];
            [_backgroundView addSubview:_messageExtraLabel];
            
            
            [self setValue:_backgroundView forKey:@"accessoryView"];
        } else {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(90, 25, 100, 100)];
            [self addSubview:_progressBar];
            
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
            [_messageLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageLabel setText:message];
            [_messageLabel setBackgroundColor:[UIColor clearColor]];
            [_messageLabel setTextColor:[UIColor whiteColor]];
            [_messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [_messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:_messageLabel];
            
            _cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [_cancelLabel setBackgroundColor:[UIColor blackColor]];
            [_cancelLabel setTextAlignment:NSTextAlignmentCenter];
            [_cancelLabel setTextColor:[UIColor whiteColor]];
            [_cancelLabel setText:@"\u2718"];
            [_cancelLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            _cancelLabel.layer.cornerRadius = 15;
            _cancelLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
            _cancelLabel.layer.borderWidth = 1.5;
            
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(215, -15, 30, 30)];
            [button addSubview:_cancelLabel];
            
            [button addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];        //[iv release];
        }
        _responseData = nil;
        alertType = GIDAAlertViewProgressTime;
    }
    return  self;
}
-(void)moveProgress {
    if (progress <= 1.0) {
        progress += 0.1;
        [_progressBar updateProgress:progress];
    } else {
        [_timer invalidate];
        _timer = nil;
        [self dismissWithClickedButtonIndex:0 animated:NO];
    }
}
-(void)presentProgressBar {
    [self show];
    _timer = [NSTimer timerWithTimeInterval:timeSeconds target:self selector:@selector(moveProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

-(id) initWithSpinnerWith:(NSString *)message {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        withSpinnerOrImage = YES;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [super setTitle:@""];
            UIActivityIndicatorView *theSpinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [theSpinner setFrame:CGRectMake(50, 5, 100, 100)];
            
            [theSpinner startAnimating];
            
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 160)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            _messageExtraLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 160, 50)];
            [_messageExtraLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageExtraLabel setText:message];
            [_messageExtraLabel setBackgroundColor:[UIColor clearColor]];
            [_messageExtraLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [_messageExtraLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [_messageExtraLabel setAdjustsFontSizeToFitWidth:YES];
            
            [_backgroundView addSubview:theSpinner];
            [_backgroundView addSubview:_messageExtraLabel];
            
            [self setValue:_backgroundView forKey:@"accessoryView"];
        } else {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            UIActivityIndicatorView *theSpinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [theSpinner setFrame:CGRectMake(90, 25, 100, 100)];
            
            [theSpinner startAnimating];
            [self addSubview:theSpinner];
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
            [_messageLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageLabel setText:message];
            [_messageLabel setBackgroundColor:[UIColor clearColor]];
            [_messageLabel setTextColor:[UIColor whiteColor]];
            [_messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [_messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:_messageLabel];
        }
        _responseData = nil;
        alertType = GIDAAlertViewSpinner;
    }
    return self;
}
- (id)initWithPrompt:(NSString *)prompt cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
    _responseData = nil;
    alertType = GIDAAlertViewPrompt;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (self = [super initWithTitle:prompt message:nil delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
            [self setAlertViewStyle:UIAlertViewStylePlainTextInput];
        }
    } else {
        while ([prompt sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(240, 1000)].width > 240.0) {
            prompt = [NSString stringWithFormat:@"%@...", [prompt substringToIndex:[prompt length] - 4]];
        }
        NSString *heightString = @"\n";
        NSInteger bm;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
            bm = UILineBreakModeWordWrap;
        } else {
            bm = NSLineBreakByWordWrapping;
        }
        CGFloat height = [prompt sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:bm].height;
        for (int i = 0; i < height; i+=22) {
            heightString = [heightString stringByAppendingString:@"\n"];
        }
        
        NSString *total = [prompt stringByAppendingString:heightString];
        height = [total sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:bm].height;
        if (self = [super initWithTitle:prompt message:heightString delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
            
            _backgroundView = [[UIView alloc] initWithFrame:super.frame];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            withSpinnerOrImage = NO;
            _textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, height+10, 260.0, 31.0)];
            [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [_textField setBorderStyle:UITextBorderStyleRoundedRect];
            [_textField setTextAlignment:NSTextAlignmentCenter];
            [_textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
            [self addSubview:_textField];
            
            _alertColor = [UIColor blackColor];
        }
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    //   if (alertType == GIDAAlertViewPrompt || alertType == GIDAAlertViewNoPrompt) {
    [_backgroundView setFrame:rect];
    [self sendSubviewToBack:_backgroundView];
    _backgroundView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _backgroundView.layer.borderWidth = 1.5;
    // }
}
- (id)initWithImage:(UIImage *)image andMessage:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
    withSpinnerOrImage = NO;
    _responseData = nil;
    alertType = GIDAAlertViewPrompt;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (self = [super initWithTitle:message message:nil delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
            
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 130)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setFrame:CGRectMake(40, 5, 80, 80)];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, 160, 50)];
            [messageLabel setTextAlignment:NSTextAlignmentCenter];
            [messageLabel setText:message];
            [messageLabel setBackgroundColor:[UIColor clearColor]];
            [messageLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [messageLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [messageLabel setAdjustsFontSizeToFitWidth:YES];
            [messageLabel removeFromSuperview];
            
            [_backgroundView addSubview:imageView];
            [_backgroundView addSubview:messageLabel];
            
            [self setValue:_backgroundView forKey:@"accessoryView"];
        }
    } else {
        while ([message sizeWithFont:[UIFont systemFontOfSize:18.0]].width > 240.0) {
            message = [NSString stringWithFormat:@"%@...", [message substringToIndex:[message length] - 4]];
        }
        NSString *height = @"\n";
        for (int i = 0; i < image.size.height; i+=14) {
            height = [height stringByAppendingString:@"\n"];
        }
        if (self = [super initWithTitle:message message:height delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            CGSize imageSize = image.size;
            CGRect imageViewFrame = CGRectMake((280-imageSize.width)/2, 20.0f, imageSize.width, imageSize.height);
            [imageView setFrame:imageViewFrame];
            UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, imageSize.height+40.0, 260.0, 31.0)];
            [theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [theTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [theTextField setBorderStyle:UITextBorderStyleRoundedRect];
            [theTextField setTextAlignment:NSTextAlignmentCenter];
            [theTextField setKeyboardAppearance:UIKeyboardAppearanceAlert];
            [self addSubview:imageView];
            [self addSubview:theTextField];
            self.textField = theTextField;
            
            _alertColor = [UIColor blackColor];
            
        }
    }
    return self;
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self) {
        alertType = GIDAAlertViewNoPrompt;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
        } else {
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
            [_messageLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageLabel setText:message];
            [_messageLabel setBackgroundColor:[UIColor clearColor]];
            [_messageLabel setTextColor:[UIColor whiteColor]];
            [_messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [_messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:_messageLabel];
        }
    }
    return self;
}

-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle andMessage:(NSString *)message {
    while ([title sizeWithFont:[UIFont systemFontOfSize:18.0]].width > 240.0) {
        title = [NSString stringWithFormat:@"%@...", [title substringToIndex:[title length] - 4]];
    }
    
    if (self = [super initWithTitle:title message:@"\n" delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
        withSpinnerOrImage = NO;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)];
        [_messageLabel setBackgroundColor:[UIColor clearColor]];
        [_messageLabel setTextColor:[UIColor whiteColor]];
        [_messageLabel setTextAlignment:NSTextAlignmentCenter];
        [_messageLabel setText:message];
        [self addSubview:_messageLabel];
        _alertColor = [UIColor blackColor];
        
        _responseData = nil;
        alertType = GIDAAlertViewNoPrompt;
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _totalFileSize = response.expectedContentLength;
    _responseData = [[NSMutableData alloc] init];
    _mimeType = [response MIMEType];
    _textEncoding = [response textEncodingName];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _receivedDataBytes += [data length];
    progress = _receivedDataBytes / (float)_totalFileSize;
    [_responseData appendData:data];
    
    if (progress < 1 && progress >= 0) {
        [_progressBar updateProgress:progress];
    } else {
        [_progressBar updateProgress:1];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_progressBar updateProgress:1];
    double delayInSeconds = 0.7;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissWithClickedButtonIndex:0 animated:NO];
    });
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",[error description]);
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _responseData = nil;
        failedDownload = YES;
        _downloadError = @"Connection failed!";
        [self dismissWithClickedButtonIndex:0 animated:NO];
    });
}

-(void)cancelDownload:(id)sender {
    [_connection cancel];
    failedDownload = YES;
    _downloadError = @"Connection cancelled";
    
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

- (id)initWithProgressBarWith:(NSString *)message andURL:(NSURL *)url {
    _receivedDataBytes = 0;
    _totalFileSize = 0;
    progress = -0.1;
    withSpinnerOrImage = YES;
    failedDownload = NO;
    _responseData = nil;
    _userURL = url;
    alertType = GIDAAlertViewProgressURL;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //Cancel button, not available now due to iOS 7 can not handle modifications to alertView
        //        if(self = [super initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil]){
        if (self = [super initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil]) {
            _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(50, 5, 100, 100)];
            [_progressBar setProgressLabelColor:[UIColor grayColor]];
            [_progressBar setProgressColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 160)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            _messageExtraLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 160, 50)];
            [_messageExtraLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageExtraLabel setText:message];
            [_messageExtraLabel setBackgroundColor:[UIColor clearColor]];
            [_messageExtraLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [_messageExtraLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [_messageExtraLabel setAdjustsFontSizeToFitWidth:YES];
            [_messageExtraLabel removeFromSuperview];
            [_backgroundView addSubview:_progressBar];
            [_backgroundView addSubview:_messageExtraLabel];
            
            [self setValue:_backgroundView forKey:@"accessoryView"];
        }
    } else {
        self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        if (self) {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            
            _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(90, 25, 100, 100)];
            [self addSubview:_progressBar];
            
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 136, 200, 44)];
            [_messageLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageLabel setText:message];
            [_messageLabel setBackgroundColor:[UIColor clearColor]];
            [_messageLabel setTextColor:[UIColor whiteColor]];
            [_messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [_messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:_messageLabel];
        }
    }
    return  self;
}
- (id)initWithProgressCircleWith:(NSString *)message andURL:(NSURL *)url {
    _receivedDataBytes = 0;
    _totalFileSize = 0;
    progress = -0.1;
    withSpinnerOrImage = YES;
    failedDownload = NO;
    _responseData = nil;
    _userURL = url;
    alertType = GIDAAlertViewProgressURL;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if(self = [super initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil]){
            _progressBar = [[LoadingCircle alloc] initWithFrame:CGRectMake(50, 5, 100, 100)];
            [_progressBar setProgressLabelColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [_progressBar setProgressColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 160)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            _messageExtraLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 160, 50)];
            [_messageExtraLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageExtraLabel setText:message];
            [_messageExtraLabel setBackgroundColor:[UIColor clearColor]];
            [_messageExtraLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [_messageExtraLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [_messageExtraLabel setAdjustsFontSizeToFitWidth:YES];
            [_messageExtraLabel removeFromSuperview];
            [_backgroundView addSubview:_progressBar];
            [_backgroundView addSubview:_messageExtraLabel];
            
            [self setValue:_backgroundView forKey:@"accessoryView"];
        }
    } else {
        
        self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        if (self) {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            
            _progressBar = [[LoadingCircle alloc] initWithFrame:CGRectMake(90, 20, 100, 100)];
            [self addSubview:_progressBar];
            
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
            [_messageLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageLabel setText:message];
            [_messageLabel setBackgroundColor:[UIColor clearColor]];
            [_messageLabel setTextColor:[UIColor whiteColor]];
            [_messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [_messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:_messageLabel];
        }
    }
    return  self;
}


- (void)setColor:(UIColor *)color {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        _alertColor = color;
        if (_backgroundView) {
            [_backgroundView setBackgroundColor:color];
        }
        if (_cancelLabel) {
            [_cancelLabel setBackgroundColor:color];
        }
    } else {
        switch (alertType) {
            case GIDAAlertViewCheck:
                [_messageExtraLabel setTextColor:color];
                [_labelMark setTextColor:color];
                break;
            case GIDAAlertViewProgressURL:
                [_messageExtraLabel setTextColor:color];
                [_progressBar setProgressColor:color];
                if ([_progressBar isKindOfClass:[LoadingCircle class]]) {
                    [_progressBar  setProgressLabelColor:color];
                }
                break;
            default:
                [_messageExtraLabel setTextColor:color];
                break;
        }
    }
}

- (void)show {
    [_textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return _entered;
}
- (NSString *)message {
    return [[self messageLabel] text];
}


- (void) layoutSubviews {
    for (UIView *sub in [self subviews])
    {
        if ([sub isKindOfClass:[UIImageView class]] && sub.tag == 0) {
            [sub removeFromSuperview];
            break;
        }
    }
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}
-(void)setDelegate:(id)delegate {
    [super setDelegate:self];
    _gavdelegate = delegate;
}
-(void)presentAlertWithSpinnerAndHideAfterSelector:(SEL)selector from:(id)sender withObject:(id)object {
    [self show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [sender performSelector:selector withObject:object];
#pragma clang diagnostic pop
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self dismissWithClickedButtonIndex:0 animated:YES];
                       });
    });
}
-(id)initWithCharacter:(NSString *)character andMessage:(NSString *)message{
    withSpinnerOrImage = YES;
    _responseData = nil;
    alertType = GIDAAlertViewCheck;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (self = [super initWithTitle:nil message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil]) {
            
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 130)];
            [_backgroundView setBackgroundColor:[UIColor clearColor]];
            
            _labelMark = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 160, 80)];
            [_labelMark setTextAlignment:NSTextAlignmentCenter];
            [_labelMark setTextColor:[UIColor whiteColor]];
            [_labelMark setBackgroundColor:[UIColor clearColor]];
            [_labelMark setText:character];
            [_labelMark setFont:[UIFont fontWithName:@"ZapfDingbatsITC" size:100]];
            
            _messageExtraLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 160, 50)];
            [_messageExtraLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageExtraLabel setText:message];
            [_messageExtraLabel setBackgroundColor:[UIColor clearColor]];
            [_messageExtraLabel setTextColor:[UIColor colorWithRed:(28.0/255) green:(130.0/255) blue:(251.0/255) alpha:1]];
            [_messageExtraLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [_messageExtraLabel setAdjustsFontSizeToFitWidth:YES];
            [_messageExtraLabel removeFromSuperview];
            
            [_backgroundView addSubview:_labelMark];
            [_backgroundView addSubview:_messageExtraLabel];
            [self setValue:_backgroundView forKey:@"accessoryView"];
        }
    } else {
        self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        if (self) {
            _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
            [_backgroundView setBackgroundColor:[UIColor blackColor]];
            [_backgroundView setAlpha:0.8];
            _backgroundView.layer.cornerRadius = 15;
            [self addSubview:_backgroundView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, 200, 120)];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor whiteColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setText:character];
            [label setFont:[UIFont fontWithName:@"ZapfDingbatsITC" size:100]];
            [self addSubview:label];
            
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
            [_messageLabel setTextAlignment:NSTextAlignmentCenter];
            [_messageLabel setText:message];
            [_messageLabel setBackgroundColor:[UIColor clearColor]];
            [_messageLabel setTextColor:[UIColor whiteColor]];
            [_messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
            [_messageLabel setAdjustsFontSizeToFitWidth:YES];
            [self addSubview:_messageLabel];
        }
    }
    return self;
}
-(id)initWithCheckMarkAndMessage:(NSString *)message {
    self = [self initWithCharacter:@"âœ“" andMessage:message];
    return self;
}

-(id)initWithExclamationMarkAndMessage:(NSString *)message {
    self = [self initWithCharacter:@"â¢" andMessage:message];
    return self;
}

-(id)initWithXMarkWith:(NSString *)message {
    self = [self initWithCharacter:@"\u2718" andMessage:message];
    return self;
}
-(void)presentAlertFor:(float)seconds {
    [self show];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissWithClickedButtonIndex:0 animated:YES];
    });
}

-(NSDictionary *)getDownloadedData {
    NSDictionary *dictionary;
    if (failedDownload) {
        dictionary = [NSDictionary dictionaryWithObject:_downloadError forKey:@"error"];
    } else {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                      _responseData, @"data",
                      _userURL,      @"url",
                      _mimeType,     @"mime",
                      _textEncoding, @"encoding",
                      nil];
    }
    return dictionary;
}
-(void)progresBarStartDownload {
    [self show];
    NSURLRequest *request = [NSURLRequest requestWithURL:_userURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_connection start];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        acceptedAlert = YES;
        if (alertType == GIDAAlertViewPrompt) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                _entered = [[alertView textFieldAtIndex:0] text];
            } else {
                _entered = [[(GIDAAlertView *)alertView textField] text];
            }
        }
    } else {
        acceptedAlert = NO;
        if (alertType == GIDAAlertViewProgressURL) {
            [self cancelDownload:nil];
        }
    }
    if ([_gavdelegate respondsToSelector:@selector(alertOnClicked:)])
        [_gavdelegate alertOnClicked:(GIDAAlertView *)alertView];
    if (alertType == GIDAAlertViewPrompt) {
        [_textField resignFirstResponder];
    }
}

-(BOOL)accepted {
    return acceptedAlert;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        acceptedAlert = YES;
    } else {
        acceptedAlert = NO;
    }
    if([_gavdelegate respondsToSelector:@selector(alertOnDismiss:)])
        [_gavdelegate alertOnDismiss:(GIDAAlertView *)alertView];
    if ([_gavdelegate respondsToSelector:@selector(alertFinished:)])
        [_gavdelegate alertFinished:(GIDAAlertView *)alertView];
}
-(void)setProgressBarColor:(UIColor *)color {
    [_progressBar setProgressColor:color];
}

-(void)setKeyboard:(UIKeyboardType)keyboard {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[self textFieldAtIndex:0] setKeyboardType:keyboard];
    } else {
        [_textField setKeyboardType:keyboard];
    }
}

@end
