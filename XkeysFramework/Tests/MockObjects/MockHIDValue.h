//
//  MockHIDValue.h
//  XkeysFrameworkTests
//
//  This mimics "short" (ie. 32-bit) values only.
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

@class MockHIDElement;

@interface MockHIDValue : NSObject

@property (nonatomic, readonly) IOHIDElementRef element;
@property (nonatomic, readonly) CFIndex length;
@property (nonatomic, readonly) CFIndex integerValue;

- (instancetype)initWithElement:(MockHIDElement *)element value:(CFIndex)value;

@end
