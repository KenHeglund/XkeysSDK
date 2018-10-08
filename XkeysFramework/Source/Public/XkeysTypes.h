//
//  XkeysTypes.h
//  XkeysFramework
//
//  Created by Ken Heglund on 11/1/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

@protocol XkeysBlueRedButton, XkeysButton, XkeysControl, XkeysDevice;

/// A callback for a device-related event such as a device attachment or removal.
/// @param device An XkeysDevice instance representing the device associated with the event.
typedef void (^XkeysDeviceCallback)(id <XkeysDevice> device);

/// A callback for a control-related event such as a button press.
/// @param control An XkeysControl instance representing the control associated with the event.
/// @return Return YES to continue receiving callbacks, NO to discontinue.
typedef BOOL (^XkeysControlCallback)(id<XkeysControl> control);

/// A callback for a button event.
/// @param button An XkeysButton instance representing the button associated with the event.
/// @return Return YES to continue receiving callbacks, NO to discontinue.
typedef BOOL (^XkeysButtonCallback)(id<XkeysButton> button);

/// A callback for a control-related event involving an XkeysBlueRedButton button.
/// @param button An XkeysBlueRedButton instance representing the button associated with the event.
/// @return Return YES to continue receiving callbacks, NO to discontinue.
typedef BOOL (^XkeysBlueRedButtonCallback)(id<XkeysBlueRedButton> button);

/// Constants that identify Xkeys models.
typedef NS_ENUM(NSInteger, XkeysModel) {
    
    /// Xkeys XKE-124 T-bar
    XkeysModelXKE124Tbar = 0,
    /// Xkeys XKE-124 T-bar (Hardware Mode)
    XkeysModelXKE124TbarHWMode,
    
    /// Xkeys XK-24
    XkeysModelXK24,
    /// Xkeys XK-24 (Hardware Mode)
    XkeysModelXK24HWMode,
    
    XkeysModelUnknown = NSIntegerMax,
};

/// Constants that identify the state of Xkeys binary outputs
typedef NS_ENUM(NSInteger, XkeysBinaryState) {
    /// Output off / low
    XkeysBinaryStateLow = 0,
    /// Output on / high
    XkeysBinaryStateHigh,
};

/// Constants that identify the state of Xkeys LEDs and backlights
typedef NS_ENUM(NSInteger, XkeysLEDState) {
    /// LED / Backlight turned on
    XkeysLEDStateOff = 0,
    /// LED / Backlight turned off
    XkeysLEDStateOn,
    /// LED flashing (not valid for Backlights)
    XkeysLEDStateFlash,
};

/// Constants that identify the color of Xkeys LEDs and backlights
typedef NS_ENUM(NSInteger, XkeysLEDColor) {
    XkeysLEDColorRed = 0,
    XkeysLEDColorGreen,
    XkeysLEDColorBlue,
};

/// A string that identifies a specific Xkeys device, control, or LED.
typedef NSString * XkeysIdentifier;

/// A string that identifies a specific Xkeys device.
typedef NSString * XkeysDeviceIdentifier;

/// A string that identifies a specific control on an Xkeys device.
typedef NSString * XkeysControlIdentifier;

/// An 8-bit value that contains an Xkeys Unit ID.
typedef uint8_t XkeysUnitID;
