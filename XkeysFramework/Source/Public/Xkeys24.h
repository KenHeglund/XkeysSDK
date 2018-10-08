//
//  Xkeys24.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysBlueRedButton.h>
#import <XkeysKit/XkeysDevice.h>
#import <XkeysKit/XkeysTypes.h>

NS_ASSUME_NONNULL_BEGIN

/// An XkeysDevice subprotocol that provides access to features specific to the XK-24
@protocol Xkeys24 <XkeysDevice>

/// An XkeysLED instance representing the Green LED of the XK-24
@property (nonatomic, readonly) id<XkeysLED> greenLED;

/// An XkeysLED instance representing the Red LED of the XK-24
@property (nonatomic, readonly) id<XkeysLED> redLED;

/// An array of XkeysBlueRedButton instances representing the buttons of the XK-24
@property (nonatomic, readonly) NSArray<id<XkeysBlueRedButton>> *buttons;

/// An XkeysControl representing the Program Switch of the XK-24
@property (nonatomic, readonly) id<XkeysControl> programSwitch;

/// Returns an XkeysBlueRedButton instance representing the button with the given button number (if any).
/// @param buttonNumber The button number of the desired button.
/// @result A XkeysBlueRedButton instance with the given button number, or nil if no such button exists.
- (id<XkeysBlueRedButton> _Nullable)buttonWithButtonNumber:(NSInteger)buttonNumber;

/// Registers an XkeysBlueRedButtonCallback block to be invoked when the current value of any of the device's buttons changes.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onAnyButtonValueChangePerform:(XkeysBlueRedButtonCallback _Nullable)callback;

/// Registers an XkeysControlCallback block to be invoked when the current value of the Program Switch changes.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onProgramSwitchChangePerform:(XkeysControlCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
