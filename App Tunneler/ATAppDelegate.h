//
//  ATAppDelegate.h
//  App Tunneler
//
//  Created by Lucas Chen on 4/3/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATProxyViewController.h"
#import <AWSDK/AWController.h>
#import "ATBrowserViewController.h"

@interface ATAppDelegate : UIResponder <UIApplicationDelegate, AWSDKDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
