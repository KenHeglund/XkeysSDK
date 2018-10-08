//
//  MockHIDElement.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

@interface MockHIDElement : NSObject

@property (nonatomic, readonly) IOHIDElementCookie cookie;

- (instancetype)initWithCookie:(IOHIDElementCookie)cookie NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end
