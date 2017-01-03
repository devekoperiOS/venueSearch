//
//  LibraryAPI.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryAPI : NSObject

+ (LibraryAPI*)sharedInstance;

- (void)callAPIToGetVenuesByLatLong:(double)latitude longitude:(double)longitude;
- (void)callAPIToGetVenuesByPlaceName:(NSString *)placename;
- (void)callAPIToGetPhotos:(NSString *)venueid;

@end



