//
//  ParseOperationPhoto.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "ParseOperationPhoto.h"
#import "VenuePhotos.h"



@interface ParseOperationPhoto ()
// Redeclare appRecordList so we can modify it within this class
@property (nonatomic, strong) NSArray *appRecordList;
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;


@end


@implementation ParseOperationPhoto


- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _dataToParse = data;
    }
    return self;
}

- (void)main
{
    _workingArray = [NSMutableArray array];
    _strError = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.dataToParse options:0 error:nil];
    NSDictionary *jsonResponse = [jsonDictionary valueForKey:@"response"];
    if (jsonResponse == nil || [jsonResponse count] == 0) {
        _strError = [NSString stringWithFormat:@"%@",[[jsonDictionary valueForKey:@"meta"] valueForKey:@"errorDetail"]];
    }
    else
    {
        NSDictionary *jsonPhotos = [jsonResponse valueForKey:@"photos"];
        if (jsonPhotos == nil || [jsonPhotos count] == 0) {
            _strError = @"No photos available";
        }
        else
        {
            NSArray *venues = [jsonPhotos valueForKey:@"items"];
            if (venues == nil || [venues count] == 0) {
                _strError =@"No photos available";
            }
            else{
                for (NSDictionary *groupDic in venues) {
                    VenuePhotos *group = [[VenuePhotos alloc] init];
                    for (NSString *key in groupDic) {
                        if ([group respondsToSelector:NSSelectorFromString(key)]) {
                            [group setValue:[groupDic valueForKey:key] forKey:key];
                        }
                    }
                    [self.workingArray addObject:group];
                }
            }
        }
    }
    
    if (![self isCancelled])
    {
        self.appRecordList = [NSArray arrayWithArray:self.workingArray];
    }
    self.workingArray = nil;
    self.dataToParse = nil;
}


@end
