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


@implementation ATAppDelegate

#pragma mark App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //[self setURLFromManagedConfigs];    //Check managed configs for DS URL and set if applicable
    
    /*ATInitialViewController *vc = [[ATInitialViewController alloc] init];
    self.window.rootViewController = vc;*/
    
    ATBrowserViewController *vc = [[ATBrowserViewController alloc] init];
    self.window.rootViewController = vc;
    
    
    AWController *controller = [AWController clientInstance];
    controller.callbackScheme = @"apptunneler";
    controller.delegate = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if([[ATSettingsManager sharedInstance] GetSDKStatus]){
        [[AWController clientInstance] start];
    }
    
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark AWSDK Delegate

-(void)initialCheckDoneWithError:(NSError *)error{
    if(!error){
        [[[UIAlertView alloc] initWithTitle:@"Initialized" message:@"Initialization Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }else{
        NSString *message = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(void)receivedProfiles:(NSArray *)profiles{
    
}

-(void)lock{
    
}

-(void)unlock{
    
}

-(void)wipe{
    
}

-(void)resumeNetworkActivity{
    
}

-(void)stopNetworkActivity{
    
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
