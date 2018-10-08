//
//  XkeysTestHIDSystem.h
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import "XkeysHIDSystem.h"

@class MockHIDManager;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysTestHIDSystem : NSObject <XkeysHIDSystem>

@property (nonatomic, readonly) MockHIDManager *hidManager;
@property (nonatomic, readonly) NSMutableArray *devices;

@end

NS_ASSUME_NONNULL_END
