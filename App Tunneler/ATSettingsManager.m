//
//  ATSettingsManager.m
//  SDKExampleApplication
//
//  Created by Lucas Chen on 4/4/14.
//
//

#import "ATSettingsManager.h"

@implementation ATSettingsManager{
    NSUserDefaults *defaults;
}

static ATSettingsManager *sharedInstance = nil;

+(ATSettingsManager*)sharedInstance{
    if(sharedInstance == nil){
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}



-(void)SetHomeAddress:(NSString *)url{
    
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"HomeURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(NSString*)GetHomeAddress{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HomeURL"];
}

-(void)EnableSDK{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"EnableSDK"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void)DisableSDK{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"EnableSDK"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)GetSDKStatus{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"EnableSDK"];
}

@end
