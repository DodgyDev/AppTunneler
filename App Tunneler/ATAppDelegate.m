//
//  ATAppDelegate.m
//  App Tunneler
//
//  Created by Lucas Chen on 4/3/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ATAppDelegate.h"
#import <AWSDK/AWServer.h>
#import <AWSDK/AWProfile.h>
#import "ATSettingsManager.h"
#import "ATLockViewController.h"


@implementation ATAppDelegate{
    ATLockViewController *lockVC;
}

#pragma mark App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    ATBrowserViewController *vc = [[ATBrowserViewController alloc] init];
    
    
    self.window.rootViewController = vc;
    
    lockVC = [[ATLockViewController alloc] init];
    
    [AWLog sharedInstance].outputDestinationMask = AWLogOutputDestinationDeviceConsole | AWLogOutputDestinationLogFile;
    
    
    
    AWController *controller = [AWController clientInstance];
    controller.callbackScheme = @"apptunneler";
    controller.delegate = self;
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if([[ATSettingsManager sharedInstance] GetSDKStatus]){
        [[AWController clientInstance] start];
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[AWController clientInstance] handleOpenURL:url fromApplication:sourceApplication];
}

#pragma mark AWSDK Delegate

-(void)initialCheckDoneWithError:(NSError *)error{
    if(!error){
        NSLog(@"Initialization Successful");
    }else{
        NSString *message = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(void)receivedProfiles:(NSArray *)profiles{
    NSLog(@"%@", [[[profiles lastObject] toDictionary] description]);
}

-(void)lock{
    
    NSLog(@"Lock Called");
    if([AWController clientInstance].ssoStatus == AWSSOStatusEnabled){
        
        [self.window.rootViewController presentViewController:lockVC animated:YES completion:^{
            
        }];
    }
}

-(void)unlock{
    if([AWController clientInstance].ssoStatus == AWSSOStatusEnabled){
        [lockVC dismissViewControllerAnimated:YES completion:^{
            
        }];

    }
   }

-(void)wipe{
    
}

-(void)resumeNetworkActivity{
    NSLog(@"Resuming network activity.");
}

-(void)stopNetworkActivity{
    NSLog(@"Disabling network activity.");

}

#pragma mark Helper Methods

-(void)setURLFromManagedConfigs{
    NSDictionary *managedConfigs = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.apple.configuration.managed"];
    
    if(managedConfigs){
        NSString *url = [managedConfigs objectForKey:@"com.AirWatch.mdm.ServerUrl"];
        if(url){
            [[AWServer sharedInstance] setDeviceServicesURL:[NSURL URLWithString:url]];
        }else{ //Has managed configs, but no SDK configs
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Managed Configs detected, but server url is not present" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }else{ //No managed configs
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No Managed Configs detected." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
@end
