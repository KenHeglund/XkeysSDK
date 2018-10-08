//
//  XkeysState.h
//  XkeysViewer
//
//  Encapsulates the generic state of an Xkeys device.  Acts as a bridge between the view controller that communicates with the XkeysKit framework, and the view that displays the state.
//
//  Created by Ken Heglund on 11/6/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import XkeysKit;

typedef void (^LEDChangeCallback)(XkeysLEDState state);
typedef void (^BacklightChangeCallback)(NSInteger buttonNumber, BOOL backlightState);

@interface XkeysState : NSObject

@property (nonatomic) XkeysLEDState greenLED;
@property (nonatomic) XkeysLEDState redLED;

@property (nonatomic, copy) LEDChangeCallback onGreenLEDChange;
@property (nonatomic, copy) LEDChangeCallback onRedLEDChange;

@property (nonatomic, copy) BacklightChangeCallback onBlueBacklightChange;
@property (nonatomic, copy) BacklightChangeCallback onRedBacklightChange;

@property (nonatomic, readonly) NSInteger minButtonNumber;
@property (nonatomic, readonly) NSInteger maxButtonNumber;

- (instancetype)initWithButtonCount:(NSInteger)numberOfButtons NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)isValidButtonNumber:(NSInteger)buttonNumber;

- (void)pressButtonNumber:(NSInteger)buttonNumber;
- (void)releaseButtonNumber:(NSInteger)buttonNumber;
- (BOOL)isButtonPressed:(NSInteger)buttonNumber;

- (BOOL)isBlueBacklightOfButtonOn:(NSInteger)buttonNumber;
- (void)setBlueBacklightOn:(BOOL)backlightState ofButton:(NSInteger)buttonNumber;
- (void)setBlueBacklightOfAllButtonsOn:(BOOL)backlightState;

- (BOOL)isRedBacklightOfButtonOn:(NSInteger)buttonNumber;
- (void)setRedBacklightOn:(BOOL)backlightState ofButton:(NSInteger)buttonNumber;
- (void)setRedBacklightOfAllButtonsOn:(BOOL)backlightState;

@end
