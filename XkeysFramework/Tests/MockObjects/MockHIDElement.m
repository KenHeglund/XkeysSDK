//
//  MockHIDElement.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "MockHIDElement.h"

@implementation MockHIDElement

- (instancetype)initWithCookie:(IOHIDElementCookie)cookie {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _cookie = cookie;
    
    return self;
}

@end
