//
//  XkeysHIDSystem.h
//  XkeysFramework
//
//  The XkeysHIDSystem protocol defines wrapper methods for macOS HID Manager functions, the interface between the framework and the system.  The primary implementation of this protocol communicates with actual hardware via the macOS HID manager.  An alternate implementation interfaces with mock objects for purposes of automated testing.
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol XkeysHIDSystem <NSObject>

// MARK: - HIDManager

- (_Nullable IOHIDManagerRef)managerCreate;

- (void)manager:(IOHIDManagerRef)hidManager setDeviceMatching:(CFDictionaryRef _Nullable)matchingParameters;

- (void)manager:(IOHIDManagerRef)hidManager registerDeviceMatchingCallback:(IOHIDDeviceCallback _Nullable)callback context:(void * _Nullable)context;

- (void)manager:(IOHIDManagerRef)hidManager scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode;
- (void)manager:(IOHIDManagerRef)hidManager unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)runLoopMode;

- (IOReturn)managerOpen:(IOHIDManagerRef)hidManager;
- (IOReturn)managerClose:(IOHIDManagerRef)hidManager;

// MARK: - HIDDevice

- (BOOL)device:(IOHIDDeviceRef)hidDevice conformsToUsagePage:(uint32_t)usagePage usage:(uint32_t)usage;

- (void)device:(IOHIDDeviceRef)hidDevice registerInputReport:(uint8_t *)report length:(CFIndex)reportLength callback:(IOHIDReportCallback _Nullable)callback context:(void * _Nullable)context;

- (IOReturn)device:(IOHIDDeviceRef)hidDevice setReport:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType;

- (void)device:(IOHIDDeviceRef)hidDevice registerRemovalCallback:(IOHIDCallback _Nullable)callback context:(void * _Nullable)context;

- (void)device:(IOHIDDeviceRef)hidDevice registerInputValueCallback:(IOHIDValueCallback _Nullable)callback context:(void * _Nullable)context;

- (void)device:(IOHIDDeviceRef)hidDevice setInputValueMatchingMultiple:(CFArrayRef _Nullable)multiple;

- (void)device:(IOHIDDeviceRef)hidDevice scheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode;
- (void)device:(IOHIDDeviceRef)hidDevice unscheduleWithRunLoop:(CFRunLoopRef)runLoop mode:(CFStringRef)runLoopMode;

- (NSInteger)deviceProductID:(IOHIDDeviceRef)hidDevice;
- (NSInteger)deviceUsagePage:(IOHIDDeviceRef)hidDevice;
- (NSInteger)deviceUsage:(IOHIDDeviceRef)hidDevice;

// MARK: - HIDElement

- (IOHIDElementCookie)elementGetCookie:(IOHIDElementRef)hidElement;

// MARK: - HIDValue

- (IOHIDElementRef)valueGetElement:(IOHIDValueRef)hidValue;
- (CFIndex)valueGetLength:(IOHIDValueRef)hidValue;
- (CFIndex)valueGetIntegerValue:(IOHIDValueRef)hidValue;

@end

NS_ASSUME_NONNULL_END
