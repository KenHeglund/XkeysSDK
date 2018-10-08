//
//  MockHIDManager.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "MockHIDDevice.h"

#import "MockHIDManager.h"

@interface MockHIDManager ()

@property (nonatomic, readwrite) NSDictionary *matchingParameters;
@property (nonatomic, readwrite) IOHIDDeviceCallback matchingCallback;
@property (nonatomic, readwrite) void *matchingCallbackContext;
@property (nonatomic, readwrite) CFRunLoopRef scheduledRunLoop;
@property (nonatomic, readwrite) CFRunLoopMode scheduledRunLoopMode;
@property (nonatomic, readwrite) BOOL isOpen;

@property (nonatomic) NSMutableArray *devices;

@end

@implementation MockHIDManager

- (instancetype)init {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _devices = [[NSMutableArray alloc] init];
    
    return self;
}

// MARK: - XkeysHIDSystem implementation

- (void)setDeviceMatching:(CFDictionaryRef)matchingParameters {
    self.matchingParameters = (__bridge NSDictionary *)matchingParameters;
}

- (void)registerDeviceMatchingCallback:(IOHIDDeviceCallback)callback context:(void *)context {
    self.matchingCallback = callback;
    self.matchingCallbackContext = context;
}

- (void)scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    self.scheduledRunLoop = runLoop;
    self.scheduledRunLoopMode = runLoopMode;
}

- (void)unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    if ( runLoop == self.scheduledRunLoop && runLoopMode == self.scheduledRunLoopMode ) {
        self.scheduledRunLoop = NULL;
        self.scheduledRunLoopMode = NULL;
    }
}

- (IOReturn)open {
    self.isOpen = YES;
    return kIOReturnSuccess;
}

- (IOReturn)close {
    self.isOpen = NO;
    return kIOReturnSuccess;
}

// MARK: - MockHIDManager implementation

- (void)attachDevice:(MockHIDDevice *)device {
    
    for ( NSString *key in self.matchingParameters.allKeys ) {
        
        if ( [key isEqualToString:@kIOHIDVendorIDKey] ) {
            
            NSNumber *vendorID = self.matchingParameters[@kIOHIDVendorIDKey];
            if ( [vendorID integerValue] != device.vendorID ) {
                return;
            }
        }
        else if ( [key isEqualToString:@kIOHIDProductIDKey] ) {
            
            NSNumber *productID = self.matchingParameters[@kIOHIDProductIDKey];
            if ( [productID integerValue] != device.productID ) {
                return;
            }
        }
    }
    
    if ( self.scheduledRunLoop == NULL ) {
        return;
    }
    if ( self.scheduledRunLoopMode == NULL ) {
        return;
    }
    if ( ! self.isOpen ) {
        return;
    }
    
    if ( self.matchingCallback == NULL ) {
        return;
    }
    
    [self.devices addObject:device];
    
    void *context = self.matchingCallbackContext;
    IOReturn result = kIOReturnSuccess;
    void *sender = (__bridge void *)self;
    IOHIDDeviceRef hidDevice = (__bridge IOHIDDeviceRef)device;
    
    self.matchingCallback( context, result, sender, hidDevice );
}

- (void)detachDevice:(MockHIDDevice *)device {
    
    if ( ! [self.devices containsObject:device] ) {
        return;
    }
    
    if ( ! self.isOpen ) {
        return;
    }
    
    [device invokeRemovalCallback];
    
    [self.devices removeObject:device];
}

@end
