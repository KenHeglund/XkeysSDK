//
//  XkeysHIDMonitor.m
//  XkeysServer
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;

#import "XkeysHIDSystem.h"

#import "XkeysHIDMonitor.h"

static void DeviceMatchingCallback(void *context, IOReturn result, void *sender, IOHIDDeviceRef hidDevice);

// MARK: - XkeysHIDMonitor private interface

@interface XkeysHIDMonitor ()

@property (nonatomic) id<XkeysHIDSystem> hidSystem;
@property (nonatomic) IOHIDManagerRef hidManager;
@property (nonatomic) BOOL isOpen;

@end

// MARK: -

@implementation XkeysHIDMonitor

- (instancetype)initWithHIDSystem:(id <XkeysHIDSystem>)hidSystem {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _hidSystem = hidSystem;
    
    return self;
}

- (void)dealloc {
    [self close];
}

// MARK: -

- (void)open {
    
    if ( self.isOpen ) {
        return;
    }
    
    self.hidManager = [self.hidSystem managerCreate];
    NSAssert(self.hidManager != nil, @"");
    if ( self.hidManager == nil ) {
        return;
    }
    
    const NSInteger PIE_USB_VID = 0x05F3;
    
    NSDictionary *matchingParameters = @{ @kIOHIDVendorIDKey : @(PIE_USB_VID) };
    [self.hidSystem manager:self.hidManager setDeviceMatching:(__bridge CFDictionaryRef)matchingParameters];
    [self.hidSystem manager:self.hidManager registerDeviceMatchingCallback:DeviceMatchingCallback context:(__bridge void *)self];
    [self.hidSystem manager:self.hidManager scheduleWithRunLoop:CFRunLoopGetMain() mode:kCFRunLoopCommonModes];
    
    IOReturn openResult = [self.hidSystem managerOpen:self.hidManager];
    NSAssert(openResult == kIOReturnSuccess, @"%@", @(openResult));
    if ( openResult != kIOReturnSuccess ) {
        return;
    }
    
    self.isOpen = YES;
}

- (void)close {
    
    if ( ! self.isOpen ) {
        return;
    }
    
    [self.hidSystem managerClose:self.hidManager];
    [self.hidSystem manager:self.hidManager unscheduleWithRunLoop:CFRunLoopGetMain() mode:kCFRunLoopCommonModes];
    [self.hidSystem manager:self.hidManager registerDeviceMatchingCallback:NULL context:NULL];
    
    CFRelease(self.hidManager);
    self.hidManager = NULL;
    
    self.isOpen = NO;
}

@end

// MARK: - Private functions

static void DeviceMatchingCallback(void *context, IOReturn result, void *sender, IOHIDDeviceRef hidDevice) {
    
    XkeysHIDMonitor *monitor = (__bridge XkeysHIDMonitor *)context;
    NSCAssert(monitor != nil, @"");
    if ( monitor == nil ) {
        return;
    }
    
    XkeysHIDDeviceAttachedCallback callback = monitor.onDeviceAttached;
    if ( callback == NULL ) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(hidDevice);
    });
}
