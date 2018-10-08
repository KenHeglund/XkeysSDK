//
//  XkeysIndexedBitInput.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/8/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XkeysBasicButton.h"

@class XkeysUnit;
@protocol XkeysDevice;

@interface XkeysIndexedBitInput : XkeysBasicButton

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device cookie:(IOHIDElementCookie)cookie bitIndex:(NSInteger)bitIndex controlIndex:(NSInteger)controlIndex NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device cookie:(IOHIDElementCookie)cookie controlIndex:(NSInteger)controlIndex NS_UNAVAILABLE;

@end
