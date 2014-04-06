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

//Instance Variables
@property (copy, nonatomic) NSString *Address;

//UI
- (IBAction)Btn_Refresh:(id)sender;
- (IBAction)Btn_Forward:(id)sender;
- (IBAction)Btn_Home:(id)sender;
- (IBAction)Btn_Back:(id)sender;
- (IBAction)Btn_Favorites:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Forward;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Refresh;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Back;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Favorites;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Home;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Settings;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Act_Loading;
@property (weak, nonatomic) IBOutlet UITextField *Txt_Address;
@property (weak, nonatomic) IBOutlet UIWebView *WebView;

//Methods
-(void)LoadURLWithAddress:(NSString*)url;


@end
