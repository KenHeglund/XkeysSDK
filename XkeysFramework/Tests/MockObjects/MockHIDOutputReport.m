//
//  MockHIDOutputReport.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;

#import "MockHIDOutputReport.h"

NS_ASSUME_NONNULL_BEGIN

@implementation MockHIDOutputReport

- (instancetype)initWithBuffer:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    NSAssert(report != NULL, @"");
    if ( report == NULL ) {
        return nil;
    }
    
    _reportData = [[NSData alloc] initWithBytes:report length:reportLength];
    _reportID = reportID;
    _reportType = reportType;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
