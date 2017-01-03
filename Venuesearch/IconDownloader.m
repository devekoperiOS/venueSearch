//
//  IconDownloader.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "IconDownloader.h"
#import "AppRecord.h"
#import "VenuePhotos.h"
#import "Constants.h"

@interface IconDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;
@property (nonatomic, strong) NSURLSessionDataTask *sessionTaskPhoto;

@end

@implementation IconDownloader


- (void)startDownload
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@%d%@",self.appRecord.prefix,@"bg_",88,self.appRecord.suffix];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (error != nil)
         {
             if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
             {
                 abort();
             }
         }
         [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
             UIImage *image = [[UIImage alloc] initWithData:data];
             self.appRecord.appIcon = image;
             if (self.completionHandler != nil){
                 self.completionHandler();
             }
         }];
     }];
    [self.sessionTask resume];
}


- (void)cancelDownload
{
    [self.sessionTask cancel];
    _sessionTask = nil;
}



- (void)startDownloadPhoto
{
    NSString *strURL = [NSString stringWithFormat:@"%@%@x%@%@",self.appRecordPhoto.prefix,self.appRecordPhoto.width,self.appRecordPhoto.height,self.appRecordPhoto.suffix];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    _sessionTaskPhoto = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil)
        {
            if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
            {
                abort();
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            UIImage *image = [[UIImage alloc] initWithData:data];
            self.appRecordPhoto.venuePhoto = image;
            if (self.completionHandlerForPhoto != nil)
            {
                self.completionHandlerForPhoto();
            }
        }];
     }];
    [self.sessionTaskPhoto resume];
}


- (void)cancelDownloadPhoto
{
    [self.sessionTaskPhoto cancel];
    _sessionTaskPhoto = nil;
}


@end
