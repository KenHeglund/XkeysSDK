//
//  XkeysUSBConnection.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import "XkeysConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface XkeysUSBConnection : NSObject <XkeysConnection>

- (instancetype)initWithHIDDevice:(IOHIDDeviceRef)hidDevice interfaceNumber:(NSInteger)interfaceNumber NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
