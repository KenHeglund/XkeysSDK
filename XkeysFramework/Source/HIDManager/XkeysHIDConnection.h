//
//  XkeysHIDConnection.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

#import "XkeysConnection.h"

@protocol XkeysHIDSystem;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysHIDConnection : NSObject <XkeysConnection>

- (instancetype)initWithHIDSystem:(id<XkeysHIDSystem>)hidSystem device:(IOHIDDeviceRef)hidDevice reportID:(CFIndex)reportID NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
