//
//  XkeysIdentifiers.h
//  XkeysFramework
//
//  This class performs all construction, parsing, and comparisons involving identifiers.
//
//  Created by Ken Heglund on 10/26/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import <XkeysKit/XkeysTypes.h>

@class XkeysInput, XkeysOutput, XkeysLEDOutput, XkeysUnit;
@protocol XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysIdentifiers : NSObject

+ (void)setProductIDMatchRequired:(BOOL)required;
+ (void)setUnitIDMatchRequired:(BOOL)required;

+ (XkeysDeviceIdentifier)identifierForUnit:(XkeysUnit<XkeysDevice> *)unit;
+ (BOOL)identifier:(XkeysIdentifier)identifier matchesUnit:(XkeysUnit<XkeysDevice> *)unit;

+ (XkeysControlIdentifier)identifierForInput:(XkeysInput *)input;
+ (BOOL)identifier:(XkeysIdentifier)identifier matchesInput:(XkeysInput *)input;

+ (XkeysControlIdentifier)identifierForOutput:(XkeysOutput *)output;
+ (BOOL)identifier:(XkeysIdentifier)identifier matchesOutput:(XkeysOutput *)output;

+ (XkeysControlIdentifier)identifierForLED:(XkeysLEDOutput *)output;
+ (BOOL)identifier:(XkeysIdentifier)identifier matchesLED:(XkeysLEDOutput *)output;

+ (XkeysDeviceIdentifier _Nullable)deviceIdentifierFromIdentifier:(XkeysIdentifier)identifier preservingUnitID:(BOOL)preserveUnitID;

@end

NS_ASSUME_NONNULL_END
