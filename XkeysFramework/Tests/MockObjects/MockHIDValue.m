//
//  MockHIDValue.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "MockHIDElement.h"

#import "MockHIDValue.h"

@implementation MockHIDValue

- (instancetype)initWithElement:(MockHIDElement *)element value:(CFIndex)value {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _element = (__bridge IOHIDElementRef)element;
    _integerValue = value;
    
    return self;
}

- (CFIndex)length {
    return sizeof(int32_t);
}

@end
