//
//  ParseOperation.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseOperation : NSOperation

@property (nonatomic, copy) void (^errorHandler)(NSError *error);
@property (nonatomic, strong, readonly) NSArray *appRecordList;
@property (nonatomic, strong) NSString *strError;

- (instancetype)initWithData:(NSData *)data;

@end
