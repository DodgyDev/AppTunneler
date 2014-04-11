//
//  ATInitialViewController.m
//  App Tunneler
//
//  Created by Lucas Chen on 4/3/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ATProxyViewController.h"
#import <AWSDK/AWProfile.h>
#import <AWSDK/AWCommandManager.h>
#import "ATSettingsManager.h"
#import "ATBrowserViewController.h"
#import <AWSDK/AWLog.h>

@interface ATProxyViewController (){
    NSNumber *_httpPort;
    NSNumber *_httpsPort;
    NSString *_host;
}

@end

@implementation ATProxyViewController
@synthesize Txt_host, Txt_httpPort, Txt_httpsPort, Btn_Dismiss, Btn_RetrieveSettings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Proxy";
        self.tabBarItem.image = [UIImage imageNamed:@"security.png"];
        NSLog(@"");
        // Custom initialization
    }
    
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.view.layer.borderWidth = 2.0;
    

    Txt_host.delegate = self;
    Txt_host.layer.borderWidth = 2.0;
    Txt_host.layer.borderColor = [UIColor darkGrayColor].CGColor;
    Txt_host.layer.cornerRadius = 2.0;
    
    Txt_httpPort.delegate = self;
    Txt_httpPort.layer.borderWidth = 2.0;
    Txt_httpPort.layer.borderColor = [UIColor darkGrayColor].CGColor;
    Txt_httpPort.layer.cornerRadius = 2.0;
    
    Txt_httpsPort.delegate = self;
    Txt_httpsPort.layer.borderWidth = 2.0;
    Txt_httpsPort.layer.borderColor = [UIColor darkGrayColor].CGColor;
    Txt_httpsPort.layer.cornerRadius = 2.0;
    
    Btn_RetrieveSettings.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_RetrieveSettings.layer.cornerRadius = 10.0;
    Btn_RetrieveSettings.layer.borderWidth = 2.0;
    Btn_RetrieveSettings.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_RetrieveSettings setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [Btn_Dismiss setTitle:@"\u25bc" forState:UIControlStateNormal];
    Btn_Dismiss.layer.backgroundColor = [UIColor whiteColor].CGColor;
    Btn_Dismiss.layer.cornerRadius = 10.0;
    Btn_Dismiss.layer.borderWidth = 2.0;
    Btn_Dismiss.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [Btn_Dismiss setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    /*
    //When view appears, if values are not filled in, try to autofill
    if([Txt_httpsPort.text isEqualToString:@""]&& [Txt_httpPort.text isEqualToString:@""] && [Txt_httpsPort.text isEqualToString:@""]){
        [self UpdateProxySettings];
    }*/
    
    AWLogError(@"Did Open Proxy Settings");
    
    if(![[ATSettingsManager sharedInstance] GetSDKStatus]){
        [[[UIAlertView alloc] initWithTitle:@"SDK Not Enabled" message:@"SDK must be enabled under General for proxy to function." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }else{
        [self UpdateProxySettings];
    }
    
    
    
    
}

-(void)UpdateProxySettings{
    [[AWCommandManager sharedManager] loadCommands];
    AWProfile *profile = [[AWCommandManager sharedManager] sdkProfile];
    AWProxyPayload *proxyPayload = [profile proxyPayload];

    
    if(profile && proxyPayload && [proxyPayload redirectTraffic]){
        _host = [proxyPayload hostName];
        _httpPort = [proxyPayload httpPort];
        _httpsPort = [proxyPayload httpsPort];
        
        Txt_host.text = _host;
        Txt_httpPort.text = [NSString stringWithFormat:@"%@", _httpPort];
        Txt_httpsPort.text = [NSString stringWithFormat:@"%@", _httpsPort];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"No Proxy Settings" message:@"No Proxy Settings Detected." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}



- (IBAction)Btn_RetrieveSettings:(id)sender {
    [self UpdateProxySettings];
}

- (IBAction)Btn_Dismiss:(id)sender {
    self.view.layer.borderWidth = 0;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}


@end
