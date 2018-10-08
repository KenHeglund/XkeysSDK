//
//  XkeysLED.h
//  XkeysFramework
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysTypes.h>

@protocol XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

/// Provides access to the properties of an LED.
@protocol XkeysLED <NSObject>

/// A user-friendly name for the LED.
@property (nonatomic, readonly) NSString *name;

/// An XkeysDevice instance that represents the device that contains this LED.
@property (nonatomic, readonly) id<XkeysDevice> device;

/// A machine parsable string that XkeysKit recognizes an identifying this specific LED.
@property (nonatomic, readonly) XkeysControlIdentifier identifier;

/// The current on/off/flash state of the LED.
@property (nonatomic, readwrite) XkeysLEDState state;

/// The color of the LED.
@property (nonatomic, readonly) XkeysLEDColor color;

@end

NS_ASSUME_NONNULL_END
