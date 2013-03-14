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

@interface GIDAAlertView : UIAlertView <NSURLConnectionDataDelegate> {
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel     *theMessage;

- (id)initWithMessage:(NSString *)someMessage andAlertImage:(UIImage *)someImage;
- (id) initWithSpinnerAndMessage:(NSString *)message;
- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;
- (NSString *) enteredText;
- (id)initWithOutTextAreaPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle andTextMessage:(NSString *)textMessage;
- (id)initWithProgressBarAndMessage:(NSString *)message andTime:(NSInteger)seconds;
- (id)initWithProgressBarAndMessage:(NSString *)message andURL:(NSURL *)url withDelegate:(id<UIAlertViewDelegate>)delegate;

- (void)setColor:(UIColor *)color;

- (void)presentProgressBar;
- (void)presentAlertFor:(float)seconds;
- (void)presentAlertWithSpinnerAndHideAfterSelector:(SEL)selector from:(id)sender withObject:(id)object;
- (void)progresBarStartDownload;

-(NSDictionary *)getDownloadedData;
@end
