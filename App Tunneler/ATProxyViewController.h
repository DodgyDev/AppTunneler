//
//  ATInitialViewController.h
//  App Tunneler
//
//  Created by Lucas Chen on 4/3/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATProxyViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *Txt_host;
@property (strong, nonatomic) IBOutlet UITextField *Txt_httpPort;
@property (strong, nonatomic) IBOutlet UITextField *Txt_httpsPort;
- (IBAction)Btn_RetrieveSettings:(id)sender;
- (IBAction)Btn_Dismiss:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *Btn_Dismiss;
@property (weak, nonatomic) IBOutlet UIButton *Btn_RetrieveSettings;

@end
