//
//  XkeysOutput.h
//  XkeysFramework
//
//  Created by Ken Heglund on 3/8/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;

@class XkeysUnit;
@protocol XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysOutput : NSObject

@property (nonatomic, readonly) XkeysUnit<XkeysDevice> *device;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSInteger controlIndex;
@property (nonatomic, readonly) NSString *identifier;

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device name:(NSString *)name controlIndex:(NSInteger)controlIndex NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
