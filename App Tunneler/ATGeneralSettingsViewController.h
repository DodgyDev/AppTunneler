//
//  ATGeneralSettingsViewController.h
//  App Tunneler
//
//  Created by Lucas Chen on 4/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATGeneralSettingsViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *Btn_Dismiss;
- (IBAction)Btn_Dismiss:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *Txt_Home;
- (IBAction)Swi_SDK:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *Swi_SDK;

@end
