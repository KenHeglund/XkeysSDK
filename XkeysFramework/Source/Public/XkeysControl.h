//
//  XkeysControl.h
//  XkeysFramework
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysTypes.h>

@protocol XkeysControl, XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

/// Provides access to the properties of a control on an Xkeys device.
@protocol XkeysControl <NSObject>

/// A user-friendly name for the control.
@property (nonatomic, readonly) NSString *name;

/// An XkeysDevice instance that represents the device that contains this control.
@property (nonatomic, readonly) id<XkeysDevice> device;

/// A machine parsable string that XkeysKit recognizes as identifying this specific control.
@property (nonatomic, readonly) XkeysControlIdentifier identifier;

/// The minimum value that the control can report.
@property (nonatomic, readonly) NSInteger minimumValue;

/// The maximum value that the control can report.
@property (nonatomic, readonly) NSInteger maximumValue;

/// The most recently reported value for the control.
@property (nonatomic, readonly) NSInteger currentValue;

/// Registers an XkeysControlCallback block to be invoked when the control's current value changes.
/// @param callback The block to be invoked.  Pass nil to clear any previously registered block.
- (void)onValueChangePerform:(XkeysControlCallback _Nullable)callback;

/// Determines whether an identifier matches the control.
/// @param identifier The identifier to be compared to the control.
/// @result Returns YES if the identifier matches the control.
- (BOOL)matchesIdentifier:(XkeysControlIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END
