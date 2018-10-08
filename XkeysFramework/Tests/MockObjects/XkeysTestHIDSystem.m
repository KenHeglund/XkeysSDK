//
//  XkeysTestHIDSystem.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;
@import ObjectiveC.runtime;

#import "MockHIDDevice.h"
#import "MockHIDElement.h"
#import "MockHIDManager.h"
#import "MockHIDValue.h"

#import "XkeysTestHIDSystem.h"

@interface XkeysTestHIDSystem ()

@property (nonatomic, readwrite) MockHIDManager *hidManager;
@property (nonatomic, readwrite) NSMutableArray *devices;

@end

@implementation XkeysTestHIDSystem

// MARK: - HIDManager functions

- (instancetype)init {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _devices = [[NSMutableArray alloc] init];
    
    return self;
}

- (IOHIDManagerRef)managerCreate {
    
    NSAssert(self.hidManager == nil, @"");
    self.hidManager = [[MockHIDManager alloc] init];
    
    /*
     Since an IOHIDManagerRef (a CFTypeRef) is being mocked by an Objective-C object, memory management is not automatic here -- CoreFoundation objects do not participate in ARC, Objective-C objects do.  This method is mocking the IOHIDManagerCreate() function which returns a retained object.  Therefore, an unbalanced retain needs to be applied to the object that is being returned here with the expectation that the caller will at some point release the object.
     */
    
    return (IOHIDManagerRef)CFBridgingRetain(self.hidManager);
}

- (void)manager:(IOHIDManagerRef)hidManager setDeviceMatching:(CFDictionaryRef _Nullable)matchingParameters {
    NSAssert((void *)hidManager == (__bridge void *)self.hidManager, @"");
    [self.hidManager setDeviceMatching:matchingParameters];
}

- (void)manager:(IOHIDManagerRef)hidManager registerDeviceMatchingCallback:(IOHIDDeviceCallback _Nullable)callback context:(void * _Nullable)context {
    NSAssert((void *)hidManager == (__bridge void *)self.hidManager, @"");
    [self.hidManager registerDeviceMatchingCallback:callback context:context];
}

- (void)manager:(IOHIDManagerRef)hidManager scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    NSAssert((void *)hidManager == (__bridge void *)self.hidManager, @"");
    [self.hidManager scheduleWithRunLoop:runLoop mode:runLoopMode];
}

- (void)manager:(IOHIDManagerRef)hidManager unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    NSAssert((void *)hidManager == (__bridge void *)self.hidManager, @"");
    [self.hidManager unscheduleWithRunLoop:runLoop mode:runLoopMode];
}

- (IOReturn)managerOpen:(IOHIDManagerRef)hidManager {
    NSAssert((void *)hidManager == (__bridge void *)self.hidManager, @"");
    return [self.hidManager open];
}

- (IOReturn)managerClose:(IOHIDManagerRef)hidManager {
    NSAssert((void *)hidManager == (__bridge void *)self.hidManager, @"");
    return [self.hidManager close];
}

// MARK: - HIDDevice functions

- (BOOL)device:(IOHIDDeviceRef)hidDevice conformsToUsagePage:(uint32_t)usagePage usage:(uint32_t)usage {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    return [(__bridge MockHIDDevice *)hidDevice conformsToUsagePage:usagePage usage:usage];
}

- (void)device:(IOHIDDeviceRef)hidDevice registerInputReport:(uint8_t *)report length:(CFIndex)reportLength callback:(IOHIDReportCallback _Nullable)callback context:(void * _Nullable)context {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    [(__bridge MockHIDDevice *)hidDevice registerInputReport:report length:reportLength callback:callback context:context];
}

- (IOReturn)device:(IOHIDDeviceRef)hidDevice setReport:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    NSAssert( report != NULL, @"" );
    [(__bridge MockHIDDevice *)hidDevice setReport:report length:reportLength reportID:reportID type:reportType];
    return kIOReturnSuccess;
}

- (void)device:(IOHIDDeviceRef)hidDevice registerRemovalCallback:(IOHIDCallback _Nullable)callback context:(void * _Nullable)context {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    [(__bridge MockHIDDevice *)hidDevice registerRemovalCallback:callback context:context];
}

- (void)device:(IOHIDDeviceRef)hidDevice registerInputValueCallback:(IOHIDValueCallback _Nullable)callback context:(void * _Nullable)context {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    [(__bridge MockHIDDevice *)hidDevice registerInputValueCallback:callback context:context];
}

- (void)device:(IOHIDDeviceRef)hidDevice setInputValueMatchingMultiple:(CFArrayRef _Nullable)multiple {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    [(__bridge MockHIDDevice *)hidDevice setInputValueMatchingMultiple:multiple];
}

- (void)device:(IOHIDDeviceRef)hidDevice scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    [(__bridge MockHIDDevice *)hidDevice scheduleWithRunLoop:runLoop mode:runLoopMode];
}

- (void)device:(IOHIDDeviceRef)hidDevice unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    [(__bridge MockHIDDevice *)hidDevice unscheduleWithRunLoop:runLoop mode:runLoopMode];
}

- (NSInteger)deviceProductID:(IOHIDDeviceRef)hidDevice {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    return ((__bridge MockHIDDevice *)hidDevice).productID;
}

- (NSInteger)deviceUsagePage:(IOHIDDeviceRef)hidDevice {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    return ((__bridge MockHIDDevice *)hidDevice).deviceUsagePage;
}

- (NSInteger)deviceUsage:(IOHIDDeviceRef)hidDevice {
    NSAssert( [(__bridge id)hidDevice isKindOfClass:[MockHIDDevice class]], @"" );
    return ((__bridge MockHIDDevice *)hidDevice).deviceUsage;
}

// MARK: - HIDElement functions

- (IOHIDElementCookie)elementGetCookie:(IOHIDElementRef)hidElement {
    NSAssert( [(__bridge id)hidElement isKindOfClass:[MockHIDElement class]], @"");
    return ((__bridge MockHIDElement *)hidElement).cookie;
}

// MARK: - HIDValue functions

- (IOHIDElementRef)valueGetElement:(IOHIDValueRef)hidValue {
    NSAssert( [(__bridge id)hidValue isKindOfClass:[MockHIDValue class]], @"");
    return ((__bridge MockHIDValue *)hidValue).element;
}

- (CFIndex)valueGetLength:(IOHIDValueRef)hidValue {
    NSAssert( [(__bridge id)hidValue isKindOfClass:[MockHIDValue class]], @"");
    return ((__bridge MockHIDValue *)hidValue).length;
}

- (CFIndex)valueGetIntegerValue:(IOHIDValueRef)hidValue {
    NSAssert( [(__bridge id)hidValue isKindOfClass:[MockHIDValue class]], @"");
    return ((__bridge MockHIDValue *)hidValue).integerValue;
}

@end
