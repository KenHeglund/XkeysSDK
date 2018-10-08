//
//  MockHIDDevice.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

@class MockHIDOutputReport, MockHIDValue;

NS_ASSUME_NONNULL_BEGIN

@interface MockHIDDevice : NSObject

@property (nonatomic, readonly) NSInteger vendorID;
@property (nonatomic, readwrite) NSInteger productID;
@property (nonatomic, readonly) NSInteger deviceUsagePage;
@property (nonatomic, readonly) NSInteger deviceUsage;

@property (nonatomic, readonly) uint8_t *inputReportBuffer;
@property (nonatomic, readonly) CFIndex inputReportBufferLength;
@property (nonatomic, readonly) IOHIDReportCallback inputReportCallback;
@property (nonatomic, readonly) void *inputReportContext;

@property (nonatomic, readonly) NSMutableArray<MockHIDOutputReport *> *outputReports;

@property (nonatomic, readonly) IOHIDCallback removalCallback;
@property (nonatomic, readonly) void *removalContext;

- (instancetype)initWithVendorID:(NSInteger)vendorID productID:(NSInteger)productID NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)conformsToUsagePage:(uint32_t)usagePage usage:(uint32_t)usage;

- (void)registerInputReport:(uint8_t * _Nonnull)report length:(CFIndex)reportLength callback:(IOHIDReportCallback _Nullable)callback context:(void * _Nullable)context;

- (IOReturn)setReport:(const uint8_t * _Nonnull)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType;

- (void)registerRemovalCallback:(IOHIDCallback _Nullable)callback context:(void * _Nullable)context;

- (void)registerInputValueCallback:(IOHIDValueCallback _Nullable)callback context:(void * _Nullable)context;
- (void)setInputValueMatchingMultiple:(CFArrayRef)multiple;

- (void)scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode;
- (void)unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode;

- (void)postInputReportOfLength:(CFIndex)reportLength withType:(IOHIDReportType)reportType reportID:(uint32_t)reportID;
- (void)postInputValue:(MockHIDValue *)mockValue;

- (void)invokeRemovalCallback;

@end

NS_ASSUME_NONNULL_END
