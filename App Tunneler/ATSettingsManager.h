//
//  ATSettingsManager.h
//  SDKExampleApplication
//
//  Created by Lucas Chen on 4/4/14.
//
//

#import <Foundation/Foundation.h>

@interface ATSettingsManager : NSObject

+ (id)sharedInstance;

-(NSString*)GetHomeAddress;
-(void)SetHomeAddress:(NSString*)url;
-(void)EnableSDK;
-(void)DisableSDK;
-(BOOL)GetSDKStatus;
@end
