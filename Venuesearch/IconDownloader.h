//
//  IconDownloader.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppRecord;
@class VenuePhotos;

@interface IconDownloader : NSObject

@property (nonatomic, strong) AppRecord *appRecord;
@property (nonatomic, strong) VenuePhotos *appRecordPhoto;
@property (nonatomic, copy) void (^completionHandler)(void);
@property (nonatomic, copy) void (^completionHandlerForPhoto)(void);


- (void)startDownload;
- (void)cancelDownload;

- (void)startDownloadPhoto;
- (void)cancelDownloadPhoto;

@end
