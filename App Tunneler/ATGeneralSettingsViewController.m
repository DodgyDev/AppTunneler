//
//  ATGeneralSettingsViewController.m
//  App Tunneler
//
//  Created by Lucas Chen on 4/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ATGeneralSettingsViewController.h"
#import "ATSettingsManager.h"
#import <AWSDK/AWController.h>

@interface ATGeneralSettingsViewController ()

@end

@implementation ATGeneralSettingsViewController
@synthesize Btn_Dismiss, Txt_Home, Swi_SDK;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"General";
        self.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor lightGrayColor].CGColor;

    Txt_Home.delegate = self;
    Txt_Home.layer.borderWidth = 2.0;
    Txt_Home.layer.borderColor = [UIColor darkGrayColor].CGColor;
    Txt_Home.layer.cornerRadius = 2.0;
    Txt_Home.text = [[ATSettingsManager sharedInstance] GetHomeAddress];
    
    [Btn_Dismiss setTitle:@"\u25bc" forState:UIControlStateNormal];
    Btn_Dismiss.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Dismiss.layer.cornerRadius = 10.0;
    Btn_Dismiss.layer.borderWidth = 2.0;
    Btn_Dismiss.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Dismiss setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [Swi_SDK setOn:[[ATSettingsManager sharedInstance] GetSDKStatus]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Btn_Dismiss:(id)sender {
    self.view.layer.borderWidth = 0;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    //Save Changes
    [[ATSettingsManager sharedInstance] SetHomeAddress:Txt_Home.text];
    if(Swi_SDK.on){
        [[ATSettingsManager sharedInstance] EnableSDK];
        [[AWController clientInstance] start];
    }else{
        [[ATSettingsManager sharedInstance] DisableSDK];
    }

}

-(void)viewDidAppear:(BOOL)animated{
 Txt_Home.text = [[ATSettingsManager sharedInstance] GetHomeAddress];
}
- (IBAction)Swi_SDK:(id)sender {
    
}
@end
