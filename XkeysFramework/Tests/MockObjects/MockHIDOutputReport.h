//
//  MockHIDOutputReport.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

@interface MockHIDOutputReport : NSObject

@property (nonatomic) NSData *reportData;
@property (nonatomic) CFIndex reportID;
@property (nonatomic) IOHIDReportType reportType;

- (instancetype)initWithBuffer:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType;

@end
