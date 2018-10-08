//
//  XkeysSliderInput.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysSliderInput.h"

@implementation XkeysSliderInput

@synthesize name = _name;

- (instancetype)initWithDevice:(id<XkeysDevice>)device cookie:(IOHIDElementCookie)cookie name:(NSString *)name controlIndex:(NSInteger)controlIndex {
    
    self = [super initWithDevice:device cookie:cookie controlIndex:controlIndex];
    if ( ! self ) {
        return nil;
    }
    
    _name = [name copy];
    
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ \"%@\"", [super debugDescription], self.name];
}

- (NSInteger)minimumValue {
    return 0;
}

- (NSInteger)maximumValue {
    return 255;
}

- (XkeysInputType)type {
    return XkeysInputTypeSlider;
}

@end
