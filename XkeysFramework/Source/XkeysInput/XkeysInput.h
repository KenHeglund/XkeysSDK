//
//  XkeysInput.h
//  XkeysFramework
//
//  This class represents a generic input from an Xkeys device.  Subclasses should provide specific handling of input values from the device.
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

#import <XkeysKit/XkeysControl.h>

typedef NS_ENUM(NSInteger, XkeysInputType) {
    XkeysInputTypeButton = 0,
    XkeysInputTypeSlider,
};

@class XkeysUnit;
@protocol XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysInput : NSObject <XkeysControl>

@property (nonatomic, readonly) XkeysUnit<XkeysDevice> *device;
@property (nonatomic, readonly) IOHIDElementCookie cookie;
@property (nonatomic, readonly) XkeysInputType type;
@property (nonatomic, readonly) NSInteger controlIndex;

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device cookie:(IOHIDElementCookie)cookie controlIndex:(NSInteger)controlIndex NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)handleInputValue:(CFIndex)value;

@end

NS_ASSUME_NONNULL_END
