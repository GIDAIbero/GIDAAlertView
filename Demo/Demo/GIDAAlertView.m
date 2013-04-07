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

@implementation ProgressBar

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blueColor]];
        CGRect rect = self.frame;
        int radius = 8;
        if (rect.size.width < 21) {
            radius = rect.size.width/3;
        }
        self.layer.cornerRadius = radius;
        [self setAlpha:0.8];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andProgressBarColor:(UIColor *)pcolor {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:pcolor];
        CGRect rect = self.frame;
        int radius = 8;
        if (rect.size.width < 21) {
            radius = rect.size.width/3;
        }
        self.layer.cornerRadius = radius;
        [self setAlpha:0.8];
    }
    return self;
}
-(void)setProgressBarColor:(UIColor *)color {
    [self setBackgroundColor:color];
}
-(void)moveBar:(CGFloat)progress {
    CGRect frame = self.frame;
    frame.size.width = 100*progress;
    self.frame = frame;
    int radius = 8;
    if (frame.size.width < 21) {
        radius = frame.size.width/3;
    }
    self.layer.cornerRadius = radius;
    [self setAlpha:0.8];
}

@end

@interface GIDAAlertView() {
    BOOL withSpinnerOrImage;
    float progress;
    NSTimer *timer;
    double timeSeconds;
    float _receivedDataBytes;
    float _totalFileSize;
    GIDAAlertViewType alertType;
    BOOL acceptedAlert;
    BOOL failedDownload;
}

@property (nonatomic, retain) UITextField     *textField;
@property (nonatomic, retain) UILabel         *theMessage;
@property (nonatomic, retain) UIColor         *alertColor;
@property (nonatomic, retain) NSTimer         *timer;
@property (nonatomic, retain) NSMutableData   *responseData;
@property (nonatomic, retain) NSURL           *userURL;
@property (nonatomic, retain) NSString        *mimeType;
@property (nonatomic, retain) NSString        *textEncoding;
@property (nonatomic, retain) ProgressBar     *progressBar;
@property (nonatomic, retain) UILabel         *progressLabel;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSString        *downloadError;
@property (nonatomic, retain) UILabel         *cancelLabel;
@property (nonatomic, retain) UIView          *backgroundView;

@end

@implementation GIDAAlertView
@synthesize timer = _timer;

-(GIDAAlertViewType)type {
    return alertType;
}

-(id)initWithMessage:(NSString *)message andAlertImage:(UIImage *)image {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        withSpinnerOrImage = YES;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setFrame:CGRectMake(100, 35, 80, 80)];
        [self addSubview:imageView];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 115, 160, 50)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setText:message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        [messageLabel release];
        [imageView release];
        
        _responseData = nil;
        alertType = GIDAAlertViewMessageImage;
    }
    return  self;
}


-(id)initWithProgressBarAndMessage:(NSString *)message andTime:(NSInteger)seconds {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        progress = -0.1;
        timeSeconds = seconds/10;
        withSpinnerOrImage = YES;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(90, 25, 0, 100)];
        [self addSubview:_progressBar];
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, -25, 200, 200)];
        [_progressLabel setTextAlignment:UITextAlignmentCenter];
        _progressLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [self addSubview:_progressLabel];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 136, 200, 44)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setText:message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        [messageLabel release];
        
        _cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [_cancelLabel setBackgroundColor:[UIColor blackColor]];
        [_cancelLabel setTextAlignment:UITextAlignmentCenter];
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
        _responseData = nil;
        alertType = GIDAAlertViewProgressTime;
    }
    return  self;
}
-(void)moveProgress {
    if (progress <= 1.0) {
        progress += 0.1;
        [_progressBar moveBar:progress];
        [_progressLabel setText:[NSString stringWithFormat:@"%0.0f%@",fabs(progress*100),@"%"]];
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

-(id) initWithSpinnerAndMessage:(NSString *)message {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        withSpinnerOrImage = YES;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        UIActivityIndicatorView *theSpinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [theSpinner setFrame:CGRectMake(90, 25, 100, 100)];
        
        [theSpinner startAnimating];
        [self addSubview:theSpinner];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 125, 180, 50)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setText:message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        [messageLabel release];
        [theSpinner release];
        _responseData = nil;
        alertType = GIDAAlertViewSpinner;
    }
    return self;
}
- (id)initWithPrompt:(NSString *)prompt cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
    while ([prompt sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(240, 1000)].width > 240.0) {
        prompt = [NSString stringWithFormat:@"%@...", [prompt substringToIndex:[prompt length] - 4]];
    }
    NSString *heightString = @"\n";
    CGFloat height = [prompt sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
    for (int i = 0; i < height; i+=22) {
        heightString = [heightString stringByAppendingString:@"\n"];
    }
    
    NSString *total = [prompt stringByAppendingString:heightString];
    height = [total sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(240, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
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
        _responseData = nil;
        alertType = GIDAAlertViewPrompt;
    }
    return self;
}
-(void)drawRect:(CGRect)rect {
    if (alertType == GIDAAlertViewPrompt || alertType == GIDAAlertViewNoPrompt) {
    [_backgroundView setFrame:rect];
    [self sendSubviewToBack:_backgroundView];
        _backgroundView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _backgroundView.layer.borderWidth = 1.5;
    }
}
- (id)initWithImage:(UIImage *)image andPrompt:(NSString *)prompt cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
    while ([prompt sizeWithFont:[UIFont systemFontOfSize:18.0]].width > 240.0) {
        prompt = [NSString stringWithFormat:@"%@...", [prompt substringToIndex:[prompt length] - 4]];
    }
    NSString *height = @"\n";
    for (int i = 0; i < image.size.height; i+=14) {
        height = [height stringByAppendingString:@"\n"];
    }
    if (self = [super initWithTitle:prompt message:height delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
        withSpinnerOrImage = NO;
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
        [theTextField release];
        [imageView release];
        
        _alertColor = [UIColor blackColor];
        
        // if not >= 4.0
        NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
        if (![sysVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedDescending) {
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0);
            [self setTransform:translate];
        }
        _responseData = nil;
        alertType = GIDAAlertViewPrompt;
    }
    return self;
}
-(id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self) {
        NSLog(@"HERE");
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        alertType = GIDAAlertViewNoPrompt;
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
        _theMessage = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)];
        [_theMessage setBackgroundColor:[UIColor clearColor]];
        [_theMessage setTextColor:[UIColor whiteColor]];
        [_theMessage setTextAlignment:NSTextAlignmentCenter];
        [_theMessage setText:message];
        [self addSubview:_theMessage];        
        _alertColor = [UIColor blackColor];
        
        // if not >= 4.0
        NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
        if (![sysVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedDescending) {
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0);
            [self setTransform:translate];
        }
        _responseData = nil;
        alertType = GIDAAlertViewNoPrompt;
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _totalFileSize = response.expectedContentLength;
    _responseData = [[NSMutableData alloc] init];
    _mimeType = [[response MIMEType] retain];
    _textEncoding = [[response textEncodingName] retain];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _receivedDataBytes += [data length];
    progress = _receivedDataBytes / (float)_totalFileSize;
    [_responseData appendData:data];

    if (progress < 1 && progress >= 0) {
        NSString *string = [NSString stringWithFormat:@"%.1f%@",progress*100,@"%"];
        [_progressLabel setText:string];
        [_progressBar moveBar:progress];
    } else {
        [_progressLabel setText:@"100%"];
        [_progressBar moveBar:1];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_progressBar moveBar:1];
    [_progressLabel setText:@"100%"];
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

- (id)initWithProgressBarAndMessage:(NSString *)message andURL:(NSURL *)url andProgressBarColor:(UIColor *)pcolor {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        _receivedDataBytes = 0;
        _totalFileSize = 0;
        progress = -0.1;
        withSpinnerOrImage = YES;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(90, 25, 0, 100) andProgressBarColor:pcolor];
        [self addSubview:_progressBar];
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, -25, 200, 200)];
        [_progressLabel setTextAlignment:UITextAlignmentCenter];
        _progressLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [self addSubview:_progressLabel];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 136, 200, 44)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setText:message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        [messageLabel release];
        
        _cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [_cancelLabel setBackgroundColor:[UIColor blackColor]];
        [_cancelLabel setTextAlignment:UITextAlignmentCenter];
        [_cancelLabel setTextColor:[UIColor whiteColor]];
        [_cancelLabel setText:@"\u2718"];
        [_cancelLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        _cancelLabel.layer.cornerRadius = 15;
        _cancelLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
        _cancelLabel.layer.borderWidth = 1.5;
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(215, -15, 30, 30)];
        [button addSubview:_cancelLabel];
        
        [button addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

        failedDownload = NO;
        _responseData = nil;
        //[iv release];
        _userURL = [url retain];
        alertType = GIDAAlertViewProgressURL;
    }
    return  self;
}
-(void)cancelDownload:(id)sender {
    [_connection cancel];
    failedDownload = YES;
    _downloadError = @"Connection cancelled";
    
    [self dismissWithClickedButtonIndex:0 animated:YES];
}
- (id)initWithProgressBarAndMessage:(NSString *)message andURL:(NSURL *)url {
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        _receivedDataBytes = 0;
        _totalFileSize = 0;
        progress = -0.1;
        withSpinnerOrImage = YES;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];
        _progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(100, 35, 0, 80)];
        [self addSubview:_progressBar];
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 50, 60, 50)];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
        _progressLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [self addSubview:_progressLabel];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 115, 160, 50)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setText:message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        [messageLabel release];
        failedDownload = NO;
        _responseData = nil;
        //[iv release];
        _userURL = [url retain];
        alertType = GIDAAlertViewProgressURL;
    }
    return  self;
}


- (void)setColor:(UIColor *)color {
    _alertColor = [color retain];
    if (_backgroundView) {
        [_backgroundView setBackgroundColor:color];
    }
    if (_cancelLabel) {
        [_cancelLabel setBackgroundColor:color];
    }
}

- (void)show {
    [_textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return _textField.text;
}
- (NSString *)message {
    return [[self theMessage] text];
}

- (void)dealloc {
    [_textField release];
    [_theMessage release];
    [_alertColor release];
    [_timer release];
    [_responseData release];
    [_userURL release];
    [_mimeType release];
    [_textEncoding release];
    [_progressBar release];
    [_progressLabel release];
    [_downloadError release];
    [_cancelLabel release];
    [_backgroundView release];
    [super dealloc];
}

- (void) layoutSubviews {
	for (UIView *sub in [self subviews])
	{
		if([sub class] == [UIImageView class] && sub.tag == 0)
		{
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
        [sender performSelector:selector withObject:object];
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self dismissWithClickedButtonIndex:0 animated:YES];
                       });
    });
}
-(id)initWithCharacter:(NSString *)character andMessage:(NSString *)message{
    self = [super initWithTitle:@"\n\n\n\n\n" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        withSpinnerOrImage = YES;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(40, -10, 200, 200)];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.8];
        _backgroundView.layer.cornerRadius = 15;
        [self addSubview:_backgroundView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 25, 200, 120)];
                [label setTextAlignment:UITextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:character];
     //   [label setFont:[UIFont systemFontOfSize:90]];
        [label setFont:[UIFont fontWithName:@"ZapfDingbatsITC" size:100]];
       // [label setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:label];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 125, 160, 50)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setText:message];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20]];
        [messageLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:messageLabel];
        [messageLabel release];
        [label release];
        _responseData = nil;
    }
    return self;
}
-(id)initWithCheckMarkAndMessage:(NSString *)message {
    self = [self initWithCharacter:@"✓" andMessage:message];
    if (self) {
        alertType = GIDAAlertViewCheck;
    }
    return self;
}

-(id)initWithExclamationMarkAndMessage:(NSString *)message {
    self = [self initWithCharacter:@"❢" andMessage:message];
    if (self) {
        alertType = GIDAAlertViewCheck;
    }
    return self;
}

-(id)initWithXMarkAndMessage:(NSString *)message {
    self = [self initWithCharacter:@"\u2718" andMessage:message];
    if (self) {
        alertType = GIDAAlertViewCheck;
    }
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
    } else {
        acceptedAlert = NO;
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
    [_progressBar setProgressBarColor:color];
}
@end
