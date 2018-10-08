//
//  XkeysState.m
//  XkeysViewer
//
//  Created by Ken Heglund on 11/6/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysState.h"

@interface XkeysState()

@property (nonatomic, readonly) NSInteger buttonCount;
@property (nonatomic) NSMutableSet *onButtonNumbers;
@property (nonatomic) NSMutableSet *onBlueBacklights;
@property (nonatomic) NSMutableSet *onRedBacklights;

@end

// MARK: -

@implementation XkeysState

- (instancetype)initWithButtonCount:(NSInteger)numberOfButtons {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _buttonCount = numberOfButtons;
    _onButtonNumbers = [[NSMutableSet alloc] init];
    _onBlueBacklights = [[NSMutableSet alloc] init];
    _onRedBacklights = [[NSMutableSet alloc] init];
    _greenLED = NO;
    _redLED = NO;
    
    return self;
}

- (NSInteger)minButtonNumber {
    return 0;
}

- (NSInteger)maxButtonNumber {
    return (self.buttonCount - 1);
}

- (BOOL)isValidButtonNumber:(NSInteger)buttonNumber {
    return ( buttonNumber >= self.minButtonNumber && buttonNumber <= self.maxButtonNumber );
}

- (void)pressButtonNumber:(NSInteger)buttonNumber {
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    [self.onButtonNumbers addObject:@(buttonNumber)];
}

- (void)releaseButtonNumber:(NSInteger)buttonNumber {
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    [self.onButtonNumbers removeObject:@(buttonNumber)];
}

- (BOOL)isButtonPressed:(NSInteger)buttonNumber {
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    return ( [self.onButtonNumbers containsObject:@(buttonNumber)] );
}

- (BOOL)isBlueBacklightOfButtonOn:(NSInteger)buttonNumber {
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    return ( [self.onBlueBacklights containsObject:@(buttonNumber)] );
}

- (void)setBlueBacklightOn:(BOOL)backlightState ofButton:(NSInteger)buttonNumber {
    
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    
    if ( backlightState ) {
        [self.onBlueBacklights addObject:@(buttonNumber)];
    }
    else {
        [self.onBlueBacklights removeObject:@(buttonNumber)];
    }
    
    BacklightChangeCallback callback = self.onBlueBacklightChange;
    if ( callback == NULL ) {
        return;
    }
    
    callback(buttonNumber, backlightState);
}

- (void)setBlueBacklightOfAllButtonsOn:(BOOL)backlightState {
    
    if ( backlightState ) {
        
        for ( NSInteger buttonNumber = self.minButtonNumber ; buttonNumber <= self.maxButtonNumber ; buttonNumber += 1 ) {
            [self.onBlueBacklights addObject:@(buttonNumber)];
        }
    }
    else {
        [self.onBlueBacklights removeAllObjects];
    }
}

- (BOOL)isRedBacklightOfButtonOn:(NSInteger)buttonNumber {
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    return ( [self.onRedBacklights containsObject:@(buttonNumber)] );
}

- (void)setRedBacklightOn:(BOOL)backlightState ofButton:(NSInteger)buttonNumber {
    
    NSAssert([self isValidButtonNumber:buttonNumber], @"%ld", buttonNumber);
    
    if ( backlightState ) {
        [self.onRedBacklights addObject:@(buttonNumber)];
    }
    else {
        [self.onRedBacklights removeObject:@(buttonNumber)];
    }
    
    BacklightChangeCallback callback = self.onRedBacklightChange;
    if ( callback == NULL ) {
        return;
    }
    
    callback(buttonNumber, backlightState);
}

- (void)setRedBacklightOfAllButtonsOn:(BOOL)backlightState {
    
    if ( backlightState ) {
        
        for ( NSInteger buttonNumber = self.minButtonNumber ; buttonNumber <= self.maxButtonNumber ; buttonNumber += 1 ) {
            [self.onRedBacklights addObject:@(buttonNumber)];
        }
    }
    else {
        [self.onRedBacklights removeAllObjects];
    }
}

- (void)setGreenLED:(XkeysLEDState)state {
    
    if ( _greenLED == state ) {
        return;
    }
    
    _greenLED = state;
    
    LEDChangeCallback callback = self.onGreenLEDChange;
    if ( callback == NULL ) {
        return;
    }
    
    callback(state);
}

- (void)setRedLED:(XkeysLEDState)state {
    
    if ( _redLED == state ) {
        return;
    }
    
    _redLED = state;
    
    LEDChangeCallback callback = self.onRedLEDChange;
    if ( callback == NULL ) {
        return;
    }
    
    callback(state);
}

@end
