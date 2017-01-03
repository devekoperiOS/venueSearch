//
//  DetailViewController.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppRecord.h"

@interface DetailViewController : UIViewController 
@property (strong, nonatomic)  AppRecord *venue;

@end
