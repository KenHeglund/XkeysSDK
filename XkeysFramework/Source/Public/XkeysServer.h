//
//  XkeysServer.h
//  XkeysFramework
//
//  XkeysServer is the principle object in the framework.
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysTypes.h>

/*!
 @typedef XkeysServerOptions
 @discussion Options to use when opening the XkeysServer instance that control how identifiers match hardware.  This is used to control whether different Xkeys devices of the same model are interchangeable with each other, or whether controls on different devices can be distinguished from each other.
 */
typedef NS_OPTIONS(NSUInteger, XkeysServerOptions) {
    /// Ignore a device's USB Product ID and Xkeys Unit ID values
    XkeysServerOptionNone = 0,
    /// Requires an identifier to match a device's USB Product ID value
    XkeysServerOptionMatchProductID = (0x01 << 0),
    /// Requires an identifier to match a device's Xkeys Unit ID value
    XkeysServerOptionMatchUnitID = (0x01 << 1),
};

@protocol XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

/// The main entry point for the XkeysKit framework.  Use the shared instance of this class to discover currently attached devices, and to register callbacks that are invoked when devices are attached or removed.
@interface XkeysServer : NSObject

/// Returns the shared XkeysServer instance.  Provides access to the currently attached Xkeys devices and notifies when devices are attached and removed.
/// @return The shared XkeysServer instance.
+ (XkeysServer *)shared;

/// An array of of XkeysDevice instances that represent the currently attached Xkeys devices.
@property (nonatomic, readonly) NSArray<id<XkeysDevice>> *devices;

/// Returns a device that matches the given identifier (if any).
/// @param identifier The identifier to match.  The identifier may specify a particular device, or a control on the device.
/// @return An XkeysDevice instance matching the given identifier, or nil if no such device is attached.
- (id<XkeysDevice> _Nullable)deviceWithIdentifier:(XkeysIdentifier)identifier;

/// Registers an XkeysDeviceCallback block to be invoked when an Xkeys device is attached. -open must be called before any callback blocks will be invoked.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onDeviceAttachPerform:(XkeysDeviceCallback _Nullable)callback;

/// Registers an XkeysDeviceCallback block to be invoked when an Xkeys device is detached.  -open must be called before any callback blocks will be invoked.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onDeviceDetachPerform:(XkeysDeviceCallback _Nullable)callback;

/// Registers an XkeysControlCallback block to be invoked when the current value of any control on any attached Xkeys device changes.  -open must be called before any callback blocks will be invoked.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onAnyControlValueChangePerform:(XkeysControlCallback _Nullable)callback;

/// Registers an XkeysControlCallback block to be invoked when the current value of the control matching the given identifier changes.  The device containing the control does not need to be attached at the time this callback is registered.  -open must be called before any callback blocks will be invoked.
/// @param controlIdentifier The identifier for the desired control.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onControlValueChange:(XkeysIdentifier)controlIdentifier perform:(XkeysControlCallback _Nullable)callback;

/// Opens the XkeysServer.  Callbacks will be invoked for any currently attached devices.
/// @param options Specifies how identifiers should match Xkeys devices.  Pass XkeysServerOptionMatchProductID to distinguish between Xkeys devices of the same model with different USB Product ID values.  Pass XkeysServerOptionMatchUnitID to distinguish between Xkeys devices of the same model with different Xkeys Unit ID values.  Pass XkeysServerOptionNone to consider all Xkeys units of the same model as identical to each other.
- (void)open:(XkeysServerOptions)options;

/// Closes the XkeysServer.  No further callbacks will be invoked once this message is sent.
- (void)close;

/*
 The following are convenience methods that may be helpful when creating presets that match against a device with an unknown Xkeys Unit ID.
 */

/// Converts an identifier for a device or a control into a device-only identifier preserving the original Xkeys Unit ID.
+ (XkeysDeviceIdentifier _Nullable)deviceIdentifierFromIdentifier:(XkeysIdentifier)identifier;

/// Converts an identifier for a device or a control into a device-only identifier that matches any Xkeys Unit ID.
+ (XkeysDeviceIdentifier _Nullable)deviceIndependentIdentifierFromIdentifier:(XkeysIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END
