//
//  MockXKE124Tbar.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "MockXkeysDevice.h"

@interface MockXKE124Tbar : MockXkeysDevice

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic) BOOL greenLEDState;
@property (nonatomic) BOOL redLEDState;

@end
