//
//  ATCertificateHandler.h
//  App Tunneler
//
//  Created by Lucas Chen on 8/28/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATCertificateHandler : NSObject

+(id)sharedInstance;
-(void)checkForCertificate;
-(void)SaveCertificateToFile:(NSData*)certData;
-(NSData*)readCertificateFromFile;
-(SecIdentityRef)certificateInformationFromCertificate:(NSData *)certificate password:(NSString *)password;
-(NSString*)GetCertificatePassword;

@end
