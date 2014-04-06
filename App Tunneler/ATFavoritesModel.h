//
//  ATFavoritesModel.h
//  App Tunneler
//
//  Created by Lucas Chen on 4/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATFavoritesModel : NSObject

-(id)initWithName:(NSString*)Name URL:(NSString*)Url;
@property (copy, nonatomic) NSString *Name;
@property (copy, nonatomic) NSString *URL;

@end
