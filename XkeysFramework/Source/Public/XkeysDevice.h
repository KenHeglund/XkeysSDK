//
//  XkeysDevice.h
//  XkeysFramework
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysTypes.h>

@protocol XkeysControl;
@protocol XkeysLED;

NS_ASSUME_NONNULL_BEGIN

/// Provides access to the properties of an Xkeys device.
@protocol XkeysDevice <NSObject>

/// A user-friendly name for the device.
@property (nonatomic, readonly) NSString *name;

/// A value identifying the general model of the device independent of its current USB Product ID.
@property (nonatomic, readonly) XkeysModel model;

/// The USB Product ID of the device.
@property (nonatomic, readwrite) NSInteger productID;

/// The Xkeys Unit ID of the device.
@property (nonatomic, readwrite) XkeysUnitID unitID;

/// A machine parsable string that XkeysKit recognizes as identifying this specific device.
@property (nonatomic, readonly) XkeysDeviceIdentifier identifier;

/// An array of XkeysControl instances that provide access to the device's buttons.
@property (nonatomic, readonly) NSArray<id<XkeysControl>> *buttons;

/// An array of XkeysLED instances that provide access to the device's LEDs.
@property (nonatomic, readonly) NSArray<id<XkeysLED>> *leds;

/// A value in the range 0.0 - 1.0 indicating the default intensity of the device's blue backlights.
@property (nonatomic, readonly) CGFloat defaultBlueBacklightIntensity;

/// A value in the range 0.0 - 1.0 indicating the default intensity of the device's red backlights.
@property (nonatomic, readonly) CGFloat defaultRedBacklightIntensity;

/// Registers an XkeysControlCallback block to be invoked when the current value of any of the device's controls changes.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onAnyControlValueChangePerform:(XkeysControlCallback _Nullable)callback;

/// Returns an XkeysControl instance representing the button with the given button number (if any).
/// @param buttonNumber The button number of the desired button.
/// @result A XkeysControl instance with the given button number, or nil if no such button exists.
- (id<XkeysControl> _Nullable)buttonWithButtonNumber:(NSInteger)buttonNumber;

/// Returns an XkeysControl instance representing a control that matches the given identifier (if any).
/// @param identifier The identifier of the desired control.
/// @result A XkeysControl instance matching the given identifier, or nil if no such control exists.
- (id<XkeysControl> _Nullable)controlWithIdentifier:(XkeysControlIdentifier)identifier;

/// Returns an XkeysLED instance representing an LED that matches the given identifier (if any).
/// @param identifier The identifier of the desired LED
/// @result A XkeysLED instance matching the given identifier, or nil if no such LED exists.
- (id<XkeysLED> _Nullable)ledWithIdentifier:(XkeysControlIdentifier)identifier;

/// Determines whether an identifier matches the device.
/// @param identifier The identifier to be compared to the control.  May be an identifier for the device itself, or for any control on the device.
/// @result Returns YES if the identifier matches the device or any of its controls.
- (BOOL)matchesIdentifier:(XkeysIdentifier)identifier;

/// Sets the on/off state of all backlights of a given color on the device.
/// @param color The color of the backlights to be controlled by this command.
/// @param state The desired state of the backlights.  XkeysLEDStateOff and XkeysLEDStateOn are the valid values for this parameter.
- (void)setAllBacklightsWithColor:(XkeysLEDColor)color toState:(XkeysLEDState)state;

/// Sets the intensity of the device's backlights
/// @param blueFraction A value in the range 0.0 - 1.0 that indicates the intensity of the blue backlights.
/// @param redFraction A value in the range 0.0 - 1.0 that indicates the intensity of the red backlights.
- (void)setCalibratedIntensityOfBacklightsToBlue:(CGFloat)blueFraction red:(CGFloat)redFraction;

/// Sets the intensity of the device's backlights
/// @param blueValue A value in the range 0x00 - 0xFF that indicates the intensity of the blue backlights.
/// @param redValue A value in the range 0x00 - 0xFF that indicates the intensity of the red backlights.
/// @note The entire range of intensity values may not be usable.
- (void)setRawIntensityOfBacklightsToBlue:(uint8_t)blueValue red:(uint8_t)redValue;

/// Writes the current state and intensity of the device's backlights to persistent EEPROM.
- (void)writeBacklightStateToEEPROM;

@end

NS_ASSUME_NONNULL_END
