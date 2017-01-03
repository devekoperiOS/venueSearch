//
//  AppRecord.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <Foundation/Foundation.h>
// Imported uikit because of use of UIImage
#import <UIKit/UIKit.h>

@interface AppRecord : NSObject

// Once the image downloading is finsihed, I have used appIcon to set image from data
@property (nonatomic, strong) UIImage *appIcon;

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *formattedPhone;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *venueRatingBlacklisted;
@property (nonatomic, strong) NSArray *formattedAddress;

@end
