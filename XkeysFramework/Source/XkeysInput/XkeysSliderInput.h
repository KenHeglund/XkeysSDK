//
//  XkeysSliderInput.h
//  XkeysFramework
//
//  This class represents a slider-style control with an output range of 0-255.
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysInput.h"
#import <XkeysKit/XkeysControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface XkeysSliderInput : XkeysInput <XkeysControl>

- (instancetype)initWithDevice:(id<XkeysDevice>)device cookie:(IOHIDElementCookie)cookie name:(NSString *)name controlIndex:(NSInteger)controlIndex NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDevice:(id<XkeysDevice>)device cookie:(IOHIDElementCookie)cookie controlIndex:(NSInteger)controlIndex NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
