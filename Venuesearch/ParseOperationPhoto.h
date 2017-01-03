//
//  ParseOperationPhoto.h
//  Venuesearch
//
//  Created by Kalpesh Parikh on 1/2/17.
//  Copyright © 2017 SJU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseOperationPhoto : NSOperation
// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);
@property (nonatomic, strong, readonly) NSArray *appRecordList;
@property (nonatomic, strong) NSString *strError;

// The initializer for this NSOperation subclass.
- (instancetype)initWithData:(NSData *)data;
@end
