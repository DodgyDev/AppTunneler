//
//  ATFavoritesModel.m
//  App Tunneler
//
//  Created by Lucas Chen on 4/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ATFavoritesModel.h"

@implementation ATFavoritesModel


-(id)init{
    self = [super init];
    if(self){
        
    }
    
    return self;
}

-(id)initWithName:(NSString*)Name URL:(NSString*)Url{
    self = [self init];
    
    if(self){
        self.Name = Name;
        self.URL = Url;
    }
    
    return self;
}

/*
static ATFavoritesModel *sharedInstance = nil;

+(ATFavoritesModel*)sharedInstance{
    if(sharedInstance == nil){
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}*/


@end
