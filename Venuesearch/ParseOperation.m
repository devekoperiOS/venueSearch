//
//  ParseOperation.m
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import "ParseOperation.h"
#import "AppRecord.h"



@interface ParseOperation ()

@property (nonatomic, strong) NSArray *appRecordList;
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;


@end


@implementation ParseOperation

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
        // handle error ...
        _strError = [NSString stringWithFormat:@"%@",[[jsonDictionary valueForKey:@"meta"] valueForKey:@"errorDetail"]];
    }
    else
    {
        
        NSArray *venues = [jsonResponse valueForKey:@"venues"];
        if(venues == nil || [venues count] == 0)
        {
            _strError = @"No venues found.";
        }
        for (NSDictionary *groupDic in venues) {
            AppRecord *group = [[AppRecord alloc] init];
            
            for (NSString *key in groupDic) {
                
                if([key isEqualToString:@"contact"])
                {
                    NSDictionary *contactDic = [groupDic valueForKey:key];
                    for (NSString *keyContact in contactDic) {
                        if ([group respondsToSelector:NSSelectorFromString(keyContact)]) {
                            [group setValue:[contactDic valueForKey:keyContact] forKey:keyContact];
                        }
                    }
                }
                if([key isEqualToString:@"location"])
                {
                    NSDictionary *locationDic = [groupDic valueForKey:key];
                    for (NSString *keyLocation in locationDic) {
                        if ([group respondsToSelector:NSSelectorFromString(keyLocation)]) {
                            [group setValue:[locationDic valueForKey:keyLocation] forKey:keyLocation];
                        }
                    }
                }
                if([key isEqualToString:@"categories"])
                {
                    NSArray *categoryArr = [groupDic valueForKey:key];
                    if([categoryArr  count] > 0)
                    {
                        NSDictionary *categoryDic = [categoryArr objectAtIndex:0];
                        for (NSString *keyCategory in categoryDic) {
                            if([keyCategory isEqualToString:@"shortName"])
                            {
                                if ([group respondsToSelector:NSSelectorFromString(keyCategory)]) {
                                    [group setValue:[categoryDic valueForKey:keyCategory] forKey:keyCategory];
                                }
                            }
                            if([keyCategory isEqualToString:@"icon"])
                            {
                                NSDictionary *iconDic = [categoryDic valueForKey:keyCategory];
                                for (NSString *keyIcon in iconDic) {
                                    if ([group respondsToSelector:NSSelectorFromString(keyIcon)]) {
                                        [group setValue:[iconDic valueForKey:keyIcon] forKey:keyIcon];
                                    }
                                }
                            }
                        }
                    }
                    
                }
                if ([group respondsToSelector:NSSelectorFromString(key)]) {
                    [group setValue:[groupDic valueForKey:key] forKey:key];
                }
            }
            [self.workingArray addObject:group];
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
