//
//  GIDASearchAlert.h 2011/10/28 to 2013/02/27
//  GIDAAlertView.h since 2013/02/27
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

#import <UIKit/UIKit.h>
typedef enum {
    GIDAAlertViewMessageImage   = 0,
    GIDAAlertViewSpinner        = 1,
    GIDAAlertViewPrompt         = 2,
    GIDAAlertViewNoPrompt       = 3,
    GIDAAlertViewProgressTime   = 4,
    GIDAAlertViewProgressURL    = 5
}GIDAAlertViewType;

@class GIDAAlertView;
@protocol GIDAAlertViewDelegate <NSObject>
@optional
-(void)alertOnClicked:(GIDAAlertView *)alertView;
-(void)alertOnDismiss:(GIDAAlertView *)alertView;
-(void)alertFinished:(GIDAAlertView *)alertView;
@end

@interface GIDAAlertView : UIAlertView <NSURLConnectionDataDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) NSString *identifier;
@property (readonly) GIDAAlertViewType type;
@property (readonly) BOOL accepted;
@property (nonatomic, retain) id <GIDAAlertViewDelegate> gavdelegate;

- (id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage;
- (id) initWithSpinnerAndMessage:(NSString *)message;
- (id)initWithPrompt:(NSString *)prompt cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;
- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle andMessage:(NSString *)message;
- (id)initWithProgressBarAndMessage:(NSString *)message andTime:(NSInteger)seconds;
- (id)initWithProgressBarAndMessage:(NSString *)message andURL:(NSURL *)url;

- (void)setColor:(UIColor *)color;
- (NSString *) enteredText;
- (NSString *) message;
- (void)presentProgressBar;
- (void)presentAlertFor:(float)seconds;
- (void)presentAlertWithSpinnerAndHideAfterSelector:(SEL)selector from:(id)sender withObject:(id)object;
- (void)progresBarStartDownload;

-(NSDictionary *)getDownloadedData;
@end
