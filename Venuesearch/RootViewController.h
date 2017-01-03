//
//  RootViewController.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController <UITableViewDataSource>

// the main data model for our UITableView
@property (nonatomic, strong) NSArray *entries;

@end
