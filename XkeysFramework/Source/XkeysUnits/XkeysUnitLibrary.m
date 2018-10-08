//
//  XkeysUnitLibrary.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysHIDConnection.h"
#import "XkeysHIDSystem.h"
#import "XkeysUSBConnection.h"
#import "Xkeys24Unit.h"
#import "Xkeys124TbarUnit.h"

#import "XkeysUnitLibrary.h"

// MARK: XkeysMapEntry

@interface XkeysMapEntry : NSObject

@property (nonatomic, readonly) Class unitClass;
@property (nonatomic, readonly) XkeysModel model;
@property (nonatomic, readonly) BOOL hidConnection;

- (instancetype)initWithClass:(Class)unitClass model:(XkeysModel)model connectViaHID:(BOOL)hidConnection;

@end

// MARK: -

@implementation XkeysMapEntry

+ (instancetype)mapEntryWithClass:(Class)unitClass model:(XkeysModel)model connectViaHID:(BOOL)hidConnection {
    return [[XkeysMapEntry alloc] initWithClass:unitClass model:model connectViaHID:hidConnection];
}

- (instancetype)initWithClass:(Class)unitClass model:(XkeysModel)model connectViaHID:(BOOL)hidConnection {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _unitClass = unitClass;
    _model = model;
    _hidConnection = hidConnection;
    
    return self;
}

@end

// MARK: -

@interface XkeysUnitLibrary ()

@property (nonatomic) id <XkeysHIDSystem> hidSystem;

@end

// MARK: - XkeysUnitLibrary

@implementation XkeysUnitLibrary

+ (NSDictionary<NSNumber *, XkeysMapEntry *> *)pidMap {
    
    static NSDictionary *pidMap = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once( &onceToken, ^{
        pidMap = @{
                   
            // XK-24
            @1027 : [XkeysMapEntry mapEntryWithClass:[Xkeys24Unit class] model:XkeysModelXK24 connectViaHID:YES],
            @1028 : [XkeysMapEntry mapEntryWithClass:[Xkeys24Unit class] model:XkeysModelXK24HWMode connectViaHID:NO],
            @1029 : [XkeysMapEntry mapEntryWithClass:[Xkeys24Unit class] model:XkeysModelXK24 connectViaHID:YES],
            @1249 : [XkeysMapEntry mapEntryWithClass:[Xkeys24Unit class] model:XkeysModelXK24HWMode connectViaHID:NO],

            // XKE-124 T-bar
            @1275 : [XkeysMapEntry mapEntryWithClass:[Xkeys124TbarUnit class] model:XkeysModelXKE124Tbar connectViaHID:YES],
            @1276 : [XkeysMapEntry mapEntryWithClass:[Xkeys124TbarUnit class] model:XkeysModelXKE124TbarHWMode connectViaHID:NO],
            @1277 : [XkeysMapEntry mapEntryWithClass:[Xkeys124TbarUnit class] model:XkeysModelXKE124TbarHWMode connectViaHID:NO],
            @1278 : [XkeysMapEntry mapEntryWithClass:[Xkeys124TbarUnit class] model:XkeysModelXKE124Tbar connectViaHID:YES],
        };
    });
    
    return pidMap;
}

- (instancetype)initWithHIDSystem:(id <XkeysHIDSystem>)hidSystem {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _hidSystem = hidSystem;
    
    return self;
}

- (XkeysUnit<XkeysDevice> *)makeUnitForHIDDevice:(IOHIDDeviceRef)hidDevice {
    
    NSInteger productID = [self.hidSystem deviceProductID:hidDevice];
    
    XkeysMapEntry *mapEntry = [XkeysUnitLibrary pidMap][@(productID)];
    if ( ! mapEntry ) {
        return nil;
    }
    
    Class unitClass = mapEntry.unitClass;
    BOOL hasProperInitializer = [unitClass instancesRespondToSelector:@selector(initWithHIDSystem:device:connection:)];
    NSAssert(hasProperInitializer, @"");
    if ( ! hasProperInitializer ) {
        return nil;
    }
    
    id<XkeysConnection> connection = nil;
    if ( mapEntry.hidConnection ) {
        connection = [[XkeysHIDConnection alloc] initWithHIDSystem:self.hidSystem device:hidDevice reportID:0];
    }
    else {
        connection = [[XkeysUSBConnection alloc] initWithHIDDevice:hidDevice interfaceNumber:0];
    }
    
    id unit = [[unitClass alloc] initWithHIDSystem:self.hidSystem device:hidDevice connection:connection];
    if ( unit == nil ) {
        return nil;
    }
    
    BOOL hasCorrectSuperclass = [unit isKindOfClass:[XkeysUnit class]];
    NSAssert(hasCorrectSuperclass, @"");
    if ( ! hasCorrectSuperclass ) {
        return nil;
    }
    
    BOOL conformsToCorrectProtocol = [unit conformsToProtocol:@protocol(XkeysDevice)];
    NSAssert(conformsToCorrectProtocol, @"");
    if ( ! conformsToCorrectProtocol ) {
        return nil;
    }
    
    return unit;
}

+ (XkeysModel)modelFromProductID:(NSInteger)productID {
    
    XkeysMapEntry *mapEntry = [XkeysUnitLibrary pidMap][@(productID)];
    if ( ! mapEntry ) {
        return XkeysModelUnknown;
    }
    
    return mapEntry.model;
}

@end
