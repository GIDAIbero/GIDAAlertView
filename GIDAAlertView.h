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
#import <QuartzCore/QuartzCore.h>

typedef enum {
    GIDAAlertViewMessageImage,
    GIDAAlertViewSpinner,
    GIDAAlertViewPrompt,
    GIDAAlertViewNoPrompt,
    GIDAAlertViewProgressTime,
    GIDAAlertViewProgressURL,
    GIDAAlertViewCheck,
    GIDAAlertViewXMark
}GIDAAlertViewType;

@class GIDAAlertView;
/**
 * Methods that the GIDAAlertView delegate must implement.
 */
@protocol GIDAAlertViewDelegate <NSObject>
@optional
/** Tells the delegate that an alert has been clicked.

@param alertView The alert view that sends the notification */
-(void)alertOnClicked:(GIDAAlertView *)alertView;
/** Tells the delegate that an alert has been dismised.
 
 @param alertView The alert view that sends the notification */
-(void)alertOnDismiss:(GIDAAlertView *)alertView;
/** Tells the delegate that an alert has been clicked, dismissed and finished background activities.
 
 @param alertView The alert view that sends the notification */
-(void)alertFinished:(GIDAAlertView *)alertView;
@end

/**
 * Description of GIDAAlertView
 */
@interface GIDAAlertView : UIAlertView <NSURLConnectionDataDelegate, UIAlertViewDelegate>
/** @name Attributes */
@property (nonatomic, strong) NSString *identifier;
@property (readonly) GIDAAlertViewType type;
@property (readonly) BOOL accepted;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id <GIDAAlertViewDelegate> gavdelegate;

/** @name Initialization */

/** Initialization of a GIDAAlertView with an check mark and a message.
 
 An NSString presented along with a check mark
 @param message String with the message to present
 @return A GIDAAlertView object or `nil` if it could not be created. */
- (id)initWithCheckMarkAndMessage:(NSString *)message;

/** Initialization of a GIDAAlertView with an exclamation mark and a message.
 
 An NSString presented along with a exclamation mark
 @param message String with the message to present
 @return A GIDAAlertView object or `nil` if it could not be created. */
- (id)initWithExclamationMarkAndMessage:(NSString *)message;

/** Initialization of a GIDAAlertView with an image and prompt
 
 Creates an alert that presents an image and a prompt. This can be used for confirming that the user is a real user. This can be used for CAPTCHA requests
 
 @param image An image to present in the alertview
 @param message The message to present in the alert
 @param cancelTitle String for the cancel button
 @param acceptTitle String for the accept button
 @return A GIDAAlertView object or `nil` if it could not be created. */
- (id)initWithImage:(UIImage *)image andMessage:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;

/** Initialization of a GIDAAlertView with a message and an image.
 
 An NSString and a UIImage to be presented in the alert
@param someMessage String with the message
@param someImage Image to show in alert
@return A GIDAAlertView object or `nil` if it could not be created.*/
- (id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage;

/** Initialization of a GIDAAlertView with a message and a graphic spinner.
 
 An NSString presented along with a UIActivityIndicatorView in the alert
@param message String with the message to present
@return A GIDAAlertView object or `nil` if it could not be created. */
- (id) initWithSpinnerWith:(NSString *)message;
- (id)initWithPrompt:(NSString *)prompt cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle andMessage:(NSString *)message;
- (id)initWithProgressBarWith:(NSString *)message andTime:(NSInteger)seconds;
- (id)initWithProgressBarWith:(NSString *)message andURL:(NSURL *)url;
- (id)initWithProgressCircleWith:(NSString *)message andURL:(NSURL *)url;
- (id)initWithXMarkWith:(NSString *)message;

/** @name Other Methods */
- (void)setColor:(UIColor *)color;
- (NSString *) enteredText;
- (void)presentProgressBar;
- (void)presentAlertFor:(float)seconds;
- (void)presentAlertWithSpinnerAndHideAfterSelector:(SEL)selector from:(id)sender withObject:(id)object;
- (void)progresBarStartDownload;

- (NSDictionary *)getDownloadedData;
- (void)setProgressBarColor:(UIColor *)color;
@end
