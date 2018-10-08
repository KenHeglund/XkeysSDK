//
//  XkeysHIDMonitor.h
//  XkeysServer
//
//  XkeysHIDMonitor connects to the HID Manager and registers a function to be called when a device with PI Engineering's USB Vendor ID is attached.
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

@protocol XkeysHIDSystem;

NS_ASSUME_NONNULL_BEGIN

typedef void (^XkeysHIDDeviceAttachedCallback)(IOHIDDeviceRef hidDeviceRef);

@interface XkeysHIDMonitor : NSObject

@property (nonatomic, copy) XkeysHIDDeviceAttachedCallback onDeviceAttached;

- (instancetype)initWithHIDSystem:(id <XkeysHIDSystem>)hidSystem NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)open;
- (void)close;

@end

NS_ASSUME_NONNULL_END
