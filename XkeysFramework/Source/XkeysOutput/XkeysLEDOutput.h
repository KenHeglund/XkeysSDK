//
//  XkeysLEDOutput.h
//  XkeysFramework
//
//  This class represents an LED output on an Xkeys device.
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysTypes.h>
#import <XkeysKit/XkeysLED.h>

#import "XkeysOutput.h"

@class XkeysUnit;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysLEDOutput : XkeysOutput <XkeysLED>

@property (nonatomic) XkeysLEDState ledState;
@property (nonatomic, copy) void (^onStateChange)(XkeysLEDState state);

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device color:(XkeysLEDColor)color controlIndex:(NSInteger)controlIndex NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device name:(NSString *)name controlIndex:(NSInteger)controlIndex NS_UNAVAILABLE;

+ (NSString *)nameForColor:(XkeysLEDColor)color;

@end

NS_ASSUME_NONNULL_END
