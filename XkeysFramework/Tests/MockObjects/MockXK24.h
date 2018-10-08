//
//  MockXK24.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "MockXkeysDevice.h"

@interface MockXK24 : MockXkeysDevice

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic) BOOL greenLEDState;
@property (nonatomic) BOOL redLEDState;

@end
