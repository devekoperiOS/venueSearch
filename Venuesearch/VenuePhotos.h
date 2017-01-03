//
//  VenuePhotos.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <Foundation/Foundation.h>
// Imported uikit because of use of UIImage
#import <UIKit/UIKit.h>

@interface VenuePhotos : NSObject

// Once the image downloading is finsihed, I have used appIcon to set image from data
@property (nonatomic, strong) UIImage *venuePhoto;

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@end
