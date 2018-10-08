//
//  MockHIDManager.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

@class MockHIDDevice;

NS_ASSUME_NONNULL_BEGIN

@interface MockHIDManager : NSObject

@property (nonatomic, readonly) NSDictionary *matchingParameters;
@property (nonatomic, readonly) IOHIDDeviceCallback matchingCallback;
@property (nonatomic, readonly) void *matchingCallbackContext;
@property (nonatomic, readonly) CFRunLoopRef scheduledRunLoop;
@property (nonatomic, readonly) CFRunLoopMode scheduledRunLoopMode;
@property (nonatomic, readonly) BOOL isOpen;

- (void)setDeviceMatching:(CFDictionaryRef _Nullable)matchingParameters;

- (void)registerDeviceMatchingCallback:(IOHIDDeviceCallback _Nullable)callback context:(void * _Nullable)context;

- (void)scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode;
- (void)unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode;

- (IOReturn)open;
- (IOReturn)close;

- (void)attachDevice:(MockHIDDevice *)device;
- (void)detachDevice:(MockHIDDevice *)device;

@end

NS_ASSUME_NONNULL_END
