//
//  ATTableViewViewController.h
//  App Tunneler
//
//  Created by Lucas Chen on 4/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATBrowserViewController.h"

@interface ATFavoritesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) ATBrowserViewController *browser;
@end
