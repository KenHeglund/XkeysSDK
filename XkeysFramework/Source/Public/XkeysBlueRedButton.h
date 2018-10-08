//
//  XkeysBlueRedButton.h
//  XkeysFramework
//
//  Created by Ken Heglund on 10/31/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysButton.h>

@protocol XkeysLED;

NS_ASSUME_NONNULL_BEGIN

/// Provides access to the blue and red backlights of a button.
@protocol XkeysBlueRedButton <XkeysButton>

/// An XkeysLED instance representing the button's blue LED.
@property (nonatomic, readonly) id<XkeysLED> blueLED;

/// An XkeysLED instance representing the button's red LED.
@property (nonatomic, readonly) id<XkeysLED> redLED;

@end

NS_ASSUME_NONNULL_END
