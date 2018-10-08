//
//  MockXkeysDevice.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import <XkeysKit/XkeysTypes.h>

#import "MockHIDDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockXkeysDevice : MockHIDDevice

@property (nonatomic) XkeysUnitID unitID;

+ (BOOL)areZerosInReport:(const uint8_t *)report fromIndex:(size_t)startIndex toIndex:(size_t)endIndex;

- (instancetype)initWithProductID:(NSInteger)productID;

@end

NS_ASSUME_NONNULL_END
