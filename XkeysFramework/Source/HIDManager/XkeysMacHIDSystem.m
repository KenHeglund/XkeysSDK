//
//  XkeysMacHIDSystem.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;

#import "XkeysMacHIDSystem.h"

@implementation XkeysMacHIDSystem

// MARK: - HIDManager functions

- (IOHIDManagerRef _Nullable)managerCreate {
    return IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDManagerOptionNone);
}

- (void)manager:(IOHIDManagerRef)hidManager setDeviceMatching:(CFDictionaryRef _Nullable)matchingParameters {
    return IOHIDManagerSetDeviceMatching(hidManager, matchingParameters);
}

- (void)manager:(IOHIDManagerRef)hidManager registerDeviceMatchingCallback:(IOHIDDeviceCallback _Nullable)callback context:(void * _Nullable)context {
    return IOHIDManagerRegisterDeviceMatchingCallback(hidManager, callback, context);
}

- (void)manager:(IOHIDManagerRef)hidManager scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    return IOHIDManagerScheduleWithRunLoop(hidManager, runLoop, runLoopMode);
}

- (void)manager:(IOHIDManagerRef)hidManager unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode {
    return IOHIDManagerUnscheduleFromRunLoop(hidManager, runLoop, runLoopMode);
}

- (IOReturn)managerOpen:(IOHIDManagerRef)hidManager {
    return IOHIDManagerOpen(hidManager, kIOHIDManagerOptionNone);
}

- (IOReturn)managerClose:(IOHIDManagerRef)hidManager {
    return IOHIDManagerClose(hidManager, kIOHIDManagerOptionNone);
}

// MARK: - HIDDevice functions

- (BOOL)device:(IOHIDDeviceRef)hidDevice conformsToUsagePage:(uint32_t)usagePage usage:(uint32_t)usage {
    return IOHIDDeviceConformsTo(hidDevice, usagePage, usage);
}

- (void)device:(IOHIDDeviceRef)hidDevice registerInputReport:(uint8_t *)report length:(CFIndex)reportLength callback:(IOHIDReportCallback _Nullable)callback context:(void * _Nullable)context {
    return IOHIDDeviceRegisterInputReportCallback(hidDevice, report, reportLength, callback, context);
}

- (IOReturn)device:(IOHIDDeviceRef)hidDevice setReport:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType {
    return IOHIDDeviceSetReport(hidDevice, reportType, reportID, report, reportLength);
}

- (void)device:(IOHIDDeviceRef)hidDevice registerRemovalCallback:(IOHIDCallback _Nullable)callback context:(void * _Nullable)context {
    return IOHIDDeviceRegisterRemovalCallback(hidDevice, callback, context);
}

- (void)device:(IOHIDDeviceRef)hidDevice registerInputValueCallback:(IOHIDValueCallback _Nullable)callback context:(void * _Nullable)context {
    return IOHIDDeviceRegisterInputValueCallback(hidDevice, callback, context);
}

- (void)device:(IOHIDDeviceRef)hidDevice setInputValueMatchingMultiple:(CFArrayRef _Nullable)multiple {
    return IOHIDDeviceSetInputValueMatchingMultiple(hidDevice, multiple);
}

- (void)device:(IOHIDDeviceRef)hidDevice scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode {
    return IOHIDDeviceScheduleWithRunLoop(hidDevice, runLoop, runLoopMode);
}

- (void)device:(IOHIDDeviceRef)hidDevice unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode {
    return IOHIDDeviceUnscheduleFromRunLoop(hidDevice, runLoop, runLoopMode);
}

- (NSInteger)deviceProductID:(IOHIDDeviceRef)hidDevice {
    return [XkeysMacHIDSystem deviceNumberProperty:hidDevice forKey:CFSTR(kIOHIDProductIDKey)];
}

- (NSInteger)deviceUsagePage:(IOHIDDeviceRef)hidDevice {
    return [XkeysMacHIDSystem deviceNumberProperty:hidDevice forKey:CFSTR(kIOHIDPrimaryUsagePageKey)];
}

- (NSInteger)deviceUsage:(IOHIDDeviceRef)hidDevice {
    return [XkeysMacHIDSystem deviceNumberProperty:hidDevice forKey:CFSTR(kIOHIDPrimaryUsageKey)];
}

+ (NSInteger)deviceNumberProperty:(IOHIDDeviceRef)hidDevice forKey:(CFStringRef)key {
    
    CFTypeRef propertyValue = IOHIDDeviceGetProperty(hidDevice, key);
    NSAssert(propertyValue != NULL, @"%@", (__bridge NSString *)key);
    if ( propertyValue == NULL ) {
        return 0;
    }
    NSAssert(CFGetTypeID(propertyValue) == CFNumberGetTypeID(), @"%@", (__bridge NSString *)key);
    if ( CFGetTypeID(propertyValue) != CFNumberGetTypeID() ) {
        return 0;
    }
    
    return [(__bridge NSNumber *)propertyValue integerValue];
}

// MARK: - HIDElement functions

- (IOHIDElementCookie)elementGetCookie:(IOHIDElementRef)hidElement {
    return IOHIDElementGetCookie(hidElement);
}

// MARK: - HIDValue functions

- (IOHIDElementRef)valueGetElement:(IOHIDValueRef)hidValue {
    return IOHIDValueGetElement(hidValue);
}

- (CFIndex)valueGetLength:(IOHIDValueRef)hidValue {
    return IOHIDValueGetLength(hidValue);
}

- (CFIndex)valueGetIntegerValue:(IOHIDValueRef)hidValue {
    return IOHIDValueGetIntegerValue(hidValue);
}

@end
