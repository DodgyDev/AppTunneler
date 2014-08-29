//
//  ATCertificateHandler.m
//  App Tunneler
//
//  Created by Lucas Chen on 8/28/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ATCertificateHandler.h"
#import <AWSDK/AWProfile.h>
#import <AWSDK/AWCommandManager.h>

@implementation ATCertificateHandler


+(id)sharedInstance{
    static dispatch_once_t once = 0;
    static ATCertificateHandler *certHandler = nil;
    
    dispatch_once(&once, ^{
       
        certHandler = [[ATCertificateHandler alloc] init];
        
    });
    
    return certHandler;
}

-(id)init{
    self = [super init];
    
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdatedCert:) name:AWNotificationCommandManagerInstalledNewProfile object:nil];
    }
    
    return self;
}

-(void)handleUpdatedCert:(NSNotification*)certNotification{
    AWProfile *profile = certNotification.object;
    
    if(profile.certificatePayload){
        NSLog(@"Certificate received");
        AWCertificatePayload *certPayload = profile.certificatePayload;
        
        [self SaveCertificateToFile:certPayload.certificateData];
        [self SaveCertificatePassword:certPayload.certificatePassword];
        //[self certificateInformationFromCertificate:certPayload.certificateData password:certPayload.certificatePassword];
        
    }
    
}


-(void)SaveCertificateToFile:(NSData*)certData{

    //Security? Who cares about that...?
    
    if(!certData)
        return;
    
    NSLog(@"WRITE: %@", [certData description]);
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"cert.dat"]];
    [certData writeToFile:databasePath atomically:YES];

}

-(NSData*)readCertificateFromFile{
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"cert.dat"]];
    
    NSData *certData = [[NSData alloc] initWithContentsOfFile:databasePath];
    
    NSLog(@"READ: %@", [certData description]);
    
    return certData;
}

-(void)SaveCertificatePassword:(NSString*)pwd{
    //Horrible security, I know, but this was for a demo with very tight time constraints.
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(NSString*)GetCertificatePassword{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"pwd"];
}

//Parse the certificate data and return SecIdentityRef object.
-(SecIdentityRef)certificateInformationFromCertificate:(NSData *)certificate password:(NSString *)password{
    
    if (!certificate)
		return nil;

	OSStatus status = errSecSuccess;
	CFDataRef cert = (__bridge CFDataRef)certificate;

    const void *keys[] =   { kSecImportExportPassphrase };
	const void *values[] = { (__bridge const void *)(password) };
    
    CFDictionaryRef optionsDictionary = NULL;
	optionsDictionary = CFDictionaryCreate(NULL, keys,values, (password ? 1 : 0),NULL, NULL);
	CFArrayRef items = NULL;

    status = SecPKCS12Import(cert,optionsDictionary,&items);
    
    if (status == 0) {
		CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
		
        const void *tempIdentity = NULL;
		tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
		CFRetain(tempIdentity);
		
		SecIdentityRef idy = (SecIdentityRef) tempIdentity;
        
        return idy;
    }else{
        return nil;
    }
}

-(void)checkForCertificate{
    [[AWCommandManager sharedManager] loadCommands];
}

@end
