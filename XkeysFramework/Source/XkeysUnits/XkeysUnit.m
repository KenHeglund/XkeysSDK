//
//  XkeysUnit.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/26/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysDevice.h>
#import <XkeysKit/XkeysTypes.h>

#import "XkeysConnection.h"
#import "XkeysHIDSystem.h"
#import "XkeysInput.h"
#import "XkeysUnitLibrary.h"

#import "XkeysUnit.h"

static NSString * const XkeysUnitExternalControlChangeCallbackKey = @"XkeysUnitExternalControlChangeCallbackKey";

void XkeysUnitInputValueCallback(void *context, IOReturn result, void *sender, IOHIDValueRef value);
void XkeysUnitRemovalCallback(void *context, IOReturn result, void *sender);

// MARK: - XkeysUnit private interface

@interface XkeysUnit ()

@property (nonatomic, readwrite) BOOL isOpen;
@property (nonatomic) NSMutableDictionary<NSString *, XkeysControlCallback> *controlCallbacks;

@end

// MARK: -

@implementation XkeysUnit

- (instancetype)initWithHIDSystem:(id<XkeysHIDSystem>)hidSystem device:(IOHIDDeviceRef)hidDevice connection:(id<XkeysConnection>)connection {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _hidSystem = hidSystem;
    _hidDevice = hidDevice;
    _connection = connection;
    _productID = [hidSystem deviceProductID:hidDevice];
    _controlCallbacks = [NSMutableDictionary dictionary];
    
    CFRetain(_hidDevice);
    
    void *context = (__bridge void *)self;
    [_hidSystem device:_hidDevice registerRemovalCallback:XkeysUnitRemovalCallback context:context];
    [_hidSystem device:_hidDevice scheduleWithRunLoop:CFRunLoopGetMain() mode:kCFRunLoopCommonModes];
    
    return self;
}

- (void)dealloc {
    [_hidSystem device:_hidDevice registerRemovalCallback:NULL context:NULL];
    [_hidSystem device:_hidDevice unscheduleWithRunLoop:CFRunLoopGetMain() mode:kCFRunLoopCommonModes];
    CFRelease(_hidDevice);
}

- (void)printDebugDescription {
    NSLog(@"%@", [self debugDescription]);
}

// MARK: - XkeysUnit implementation

- (XkeysModel)model {
    return [XkeysUnitLibrary modelFromProductID:self.productID];
}

- (void)setProductID:(NSInteger)productID {
    _productID = productID;
    // Subclasses must provide a unit-specific means to set the hardware productID
}

- (NSArray<XkeysInput *> *)controlInputs {
    // Subclasses must provide controls
    return @[];
}

- (void)initialUnitStateConfigured {
    [self startListeningForInputValues];
    [self invokeOnUnitConfiguredCallback];
}

- (void)open {
    [self.connection open];
    self.isOpen = YES;
}

- (void)close {
    [self stopListeningForInputValues];
    [self.connection close];
    self.isOpen = NO;
}

- (void)invokeControlValueChangeCallbacksWithControl:(id<XkeysControl>)control {
    
    for ( NSString *key in [self.controlCallbacks allKeys] ) {
        
        XkeysControlCallback callback = self.controlCallbacks[key];
        
        if ( ! callback(control) ) {
            [self.controlCallbacks removeObjectForKey:key];
        }
    }
}

- (void)onAnyControlValueChangePerform:(XkeysControlCallback _Nullable)callback {
    [self setValueChangeCallbackForKey:XkeysUnitExternalControlChangeCallbackKey callback:callback];
}

- (void)setValueChangeCallbackForKey:(NSString *)key callback:(XkeysControlCallback _Nullable)callback {
    
    if ( callback != NULL ) {
        self.controlCallbacks[key] = [callback copy];
    }
    else {
        [self.controlCallbacks removeObjectForKey:key];
    }
}

- (void)handleInputValue:(CFIndex)value fromCookie:(IOHIDElementCookie)cookie {
    
    for ( XkeysInput *controlInput in self.controlInputs ) {
        
        if ( controlInput.cookie != cookie ) {
            continue;
        }
        
        if ( ! [controlInput handleInputValue:value] ) {
            continue;
        }
        
        [self invokeControlValueChangeCallbacksWithControl:controlInput];
    }
}

// MARK: - XKeysUnit internal

- (void)startListeningForInputValues {
    
    [self registerInputValueCallbackCriteria];
    
    void *context = (__bridge void *)self;
    [self.hidSystem device:_hidDevice registerInputValueCallback:XkeysUnitInputValueCallback context:context];
}

- (void)stopListeningForInputValues {
    [self.hidSystem device:_hidDevice registerInputValueCallback:NULL context:NULL];
}

- (void)registerInputValueCallbackCriteria {
    
    NSMutableSet *cookiesToRegister = [NSMutableSet set];
    
    for ( XkeysInput *controlInput in self.controlInputs ) {
        
        /*
         This +1 offset is a workaround for what appears to be a macOS bug in handling Xkeys devices.  When requesting callbacks for a given cookie,  callbacks for cookie-1 are actually registered.  Therefore, the device's valid cookies are all increased by one for purposes of registering for value change callbacks.  When the callback is eventually called, the associated element contains the cookie value that the device expects.
         */
        NSNumber *adjustedCookie = @((NSInteger)controlInput.cookie + 1);
        
        [cookiesToRegister addObject:adjustedCookie];
    }
    
    NSMutableArray *cookieMatchArray = [NSMutableArray array];
    
    for ( NSNumber *cookie in [cookiesToRegister allObjects] ) {
        [cookieMatchArray addObject:@{ @kIOHIDElementCookieKey : cookie }];
    }
    
    [self.hidSystem device:self.hidDevice setInputValueMatchingMultiple:(__bridge CFArrayRef)cookieMatchArray];
}

- (void)invokeOnUnitConfiguredCallback {
    
    XkeysUnitCallback callback = self.onUnitConfigured;
    if ( callback == NULL ) {
        return;
    }
    
    callback(self);
}

- (void)invokeOnUnitTerminatedCallback {
    
    XkeysUnitCallback callback = self.onUnitTerminated;
    if ( callback == NULL ) {
        return;
    }
    
    callback(self);
}

@end

// MARK: - Private functions

void XkeysUnitInputValueCallback(void * _Nullable context, IOReturn result, void * _Nullable sender, IOHIDValueRef value) {
    
    XkeysUnit *unit = (__bridge XkeysUnit *)context;
    NSCAssert(unit != nil, @"");
    if ( unit == nil ) {
        return;
    }
    
    CFIndex valueSizeInBytes = [unit.hidSystem valueGetLength:value];
    NSCAssert(valueSizeInBytes <= sizeof(CFIndex), @"");
    if ( valueSizeInBytes > sizeof(CFIndex) ) {
        return;
    }
    
    IOHIDElementRef hidElement = [unit.hidSystem valueGetElement:value];
    IOHIDElementCookie cookie = [unit.hidSystem elementGetCookie:hidElement];
    CFIndex integerValue = [unit.hidSystem valueGetIntegerValue:value];
    
    [unit handleInputValue:integerValue fromCookie:cookie];
}

void XkeysUnitRemovalCallback(void *context, IOReturn result, void *sender) {
    
    XkeysUnit *unit = (__bridge XkeysUnit *)context;
    NSCAssert(unit != nil, @"");
    if ( unit == nil ) {
        return;
    }
    
    [unit invokeOnUnitTerminatedCallback];
}
