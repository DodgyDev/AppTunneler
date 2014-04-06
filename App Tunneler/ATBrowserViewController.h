//
//  ATBrowserViewController.h
//  App Tunneler
//
//  Created by Lucas Chen on 4/3/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATBrowserViewController.h"

@interface ATBrowserViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *Txt_Address;
@property (weak, nonatomic) IBOutlet UIWebView *WebView;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Settings;
@property (copy, nonatomic) NSString *Address;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Home;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Act_Loading;
- (IBAction)Btn_Settings:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Forward;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Refresh;
- (IBAction)Btn_Refresh:(id)sender;
- (IBAction)Btn_Forward:(id)sender;
- (IBAction)Btn_Home:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *Btn_Back;
- (IBAction)Btn_Back:(id)sender;

- (IBAction)Btn_Favorites:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Favorites;


-(void)LoadURLWithAddress:(NSString*)url;


@end
