//
//  XkeysUnitLibrary.h
//  XkeysFramework
//
//  This class contains knowledge of Xkeys PIDs and uses that to create XkeysUnit instances and XkeysModel values.
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;
@import IOKit.hid;

#import <XkeysKit/XkeysTypes.h>

@protocol XkeysDevice, XkeysHIDSystem;
@class XkeysUnit;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysUnitLibrary : NSObject

- (instancetype)initWithHIDSystem:(id <XkeysHIDSystem>)hidSystem NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (XkeysUnit<XkeysDevice> *)makeUnitForHIDDevice:(IOHIDDeviceRef)hidDevice;

+ (XkeysModel)modelFromProductID:(NSInteger)productID;

@end

NS_ASSUME_NONNULL_END
