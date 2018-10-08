//
//  XkeysUnit.h
//  XkeysFramework
//
//  This class contains basic implementation of, but not final conformance to, the XkeysDevice protocol.  Subclasses are expected to provide expert knowledge of specific Xkeys models and provide XkeysDevice conformance.
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

#import <XkeysKit/XkeysTypes.h>

@class XkeysInput, XkeysUnit;
@protocol XkeysConnection, XkeysControl, XkeysHIDSystem;

NS_ASSUME_NONNULL_BEGIN

typedef void (^XkeysUnitCallback)(XkeysUnit *unit);

@interface XkeysUnit: NSObject

@property (nonatomic, readonly) id<XkeysHIDSystem> hidSystem;
@property (nonatomic, readonly) IOHIDDeviceRef hidDevice;
@property (nonatomic, readonly) id<XkeysConnection> connection;
@property (nonatomic, readwrite) NSInteger productID;
@property (nonatomic, readonly) XkeysModel model;
@property (nonatomic) XkeysUnitID unitID;

@property (nonatomic, readonly) BOOL isOpen;

@property (nonatomic, copy) XkeysUnitCallback onUnitConfigured;
@property (nonatomic, copy) XkeysUnitCallback onUnitTerminated;

@property (nonatomic, readonly) NSArray<XkeysInput *> *controlInputs;

- (instancetype)initWithHIDSystem:(id<XkeysHIDSystem>)hidSystem device:(IOHIDDeviceRef)hidDevice connection:(id<XkeysConnection>)connection NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)printDebugDescription;

- (void)initialUnitStateConfigured;

- (void)open;
- (void)close;

- (void)onAnyControlValueChangePerform:(XkeysControlCallback _Nullable)callback;
- (void)setValueChangeCallbackForKey:(NSString *)key callback:(XkeysControlCallback _Nullable)callback;
- (void)invokeControlValueChangeCallbacksWithControl:(id<XkeysControl>)control;

- (void)handleInputValue:(CFIndex)value fromCookie:(IOHIDElementCookie)cookie;

@end

NS_ASSUME_NONNULL_END
