//
//  PhotoViewController.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppRecord.h"

@interface PhotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *entriesPhotos;
@property (strong, nonatomic)  AppRecord *venue;
@property (weak, nonatomic) IBOutlet UITableView *tblPhoto;

@end
