//
//  XkeysIdentifiers.m
//  XkeysFramework
//
//  Device identifier: xkeys://format_version/vid/pid/uid
//  Control identifier: xkeys://format_version/vid/pid/uid/control_specifier
//
//  Created by Ken Heglund on 10/26/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import <XkeysKit/XkeysDevice.h>
#import <XkeysKit/XkeysTypes.h>

#import "XkeysInput.h"
#import "XkeysLEDOutput.h"
#import "XkeysUnit.h"
#import "XkeysUnitLibrary.h"

#import "XkeysIdentifiers.h"

static const NSInteger FORMAT_VERSION = 1;
static const NSInteger PIE_USB_VID = 0x05F3;
static NSString * const IDENTIFIER_PREFIX = @"xkeys://";
static NSString * const BUTTON_CONTROL_SPECIFIER = @"button";
static NSString * const LED_CONTROL_SPECIFIER = @"led";
static NSString * const SLIDER_CONTROL_SPECIFIER = @"slider";
static NSString * const OUTPUT_CONTROL_SPECIFIER = @"output";

static BOOL XkeysIdentifiersRequireProductIDMatch = NO;
static BOOL XkeysIdentifiersRequireUnitIDMatch = NO;

@interface XkeysIdentifierComponents: NSObject
@property (nonatomic) NSInteger productID;
@property (nonatomic) XkeysModel model;
@property (nonatomic) NSInteger unitID; // NSIntegerMax matches any UnitID
@property (nonatomic, nullable) NSString *controlSpecifier;
@end

@implementation XkeysIdentifierComponents

@end

// MARK: -

@implementation XkeysIdentifiers

+ (void)setProductIDMatchRequired:(BOOL)required {
    XkeysIdentifiersRequireProductIDMatch = required;
}

+ (void)setUnitIDMatchRequired:(BOOL)required {
    XkeysIdentifiersRequireUnitIDMatch = required;
}

+ (XkeysDeviceIdentifier)identifierForUnit:(XkeysUnit<XkeysDevice> *)unit {
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromUnit:unit];
    return [XkeysIdentifiers identifierFromComponents:components];
}

+ (BOOL)identifier:(XkeysIdentifier)identifier matchesUnit:(XkeysUnit<XkeysDevice> *)unit {
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromIdentifier:identifier];
    return [XkeysIdentifiers components:components matchUnit:unit];
}

+ (XkeysControlIdentifier)identifierForInput:(XkeysInput *)input {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromUnit:input.device];
    
    if ( input.type == XkeysInputTypeButton ) {
        components.controlSpecifier = [XkeysIdentifiers buttonControlSpecifierWithControlIndex:input.controlIndex];
    }
    else if ( input.type == XkeysInputTypeSlider ) {
        components.controlSpecifier = [XkeysIdentifiers sliderControlSpecifierWithControlIndex:input.controlIndex];
    }
    else {
        NSAssert(NO, @"Unhandled input type: %ld", (long)input.type);
        return @"";
    }
    
    return [XkeysIdentifiers identifierFromComponents:components];
}

+ (BOOL)identifier:(XkeysIdentifier)identifier matchesInput:(XkeysInput *)input {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromIdentifier:identifier];
    
    if ( ! [XkeysIdentifiers components:components matchUnit:input.device] ) {
        return NO;
    }
    
    NSString *inputSpecifier = nil;
    
    if ( input.type == XkeysInputTypeButton ) {
        inputSpecifier = [XkeysIdentifiers buttonControlSpecifierWithControlIndex:input.controlIndex];
    }
    else if ( input.type == XkeysInputTypeSlider ) {
        inputSpecifier = [XkeysIdentifiers sliderControlSpecifierWithControlIndex:input.controlIndex];
    }
    else {
        NSAssert(NO, @"Unhandled input type: %ld", (long)input.type);
        return NO;
    }
    
    return ( [components.controlSpecifier caseInsensitiveCompare:inputSpecifier] == NSOrderedSame );
}

+ (XkeysControlIdentifier)identifierForOutput:(XkeysOutput *)output {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromUnit:output.device];
    
    components.controlSpecifier = [XkeysIdentifiers outputControlSpecifierWithControlIndex:output.controlIndex];
    
    return [XkeysIdentifiers identifierFromComponents:components];
}

+ (BOOL)identifier:(XkeysIdentifier)identifier matchesOutput:(XkeysOutput *)output {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromIdentifier:identifier];
    
    if ( ! [XkeysIdentifiers components:components matchUnit:output.device] ) {
        return NO;
    }
    
    NSString *outputSpecifier = [XkeysIdentifiers outputControlSpecifierWithControlIndex:output.controlIndex];
    
    return ( [components.controlSpecifier caseInsensitiveCompare:outputSpecifier] == NSOrderedSame );
}

+ (XkeysControlIdentifier)identifierForLED:(XkeysLEDOutput *)output {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromUnit:output.device];
    components.controlSpecifier = [XkeysIdentifiers ledControlSpecifierWithControlIndex:output.controlIndex];
    
    return [XkeysIdentifiers identifierFromComponents:components];
}

+ (BOOL)identifier:(XkeysIdentifier)identifier matchesLED:(XkeysLEDOutput *)output {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromIdentifier:identifier];
    
    if ( ! [XkeysIdentifiers components:components matchUnit:output.device] ) {
        return NO;
    }
    
    NSString *ledSpecifier = [XkeysIdentifiers ledControlSpecifierWithControlIndex:output.controlIndex];
    
    return ( [components.controlSpecifier caseInsensitiveCompare:ledSpecifier] == NSOrderedSame );
}

+ (XkeysDeviceIdentifier _Nullable)deviceIdentifierFromIdentifier:(XkeysIdentifier)identifier preservingUnitID:(BOOL)preserveUnitID {
    
    XkeysIdentifierComponents *components = [XkeysIdentifiers componentsFromIdentifier:identifier];
    if ( components == nil ) {
        return nil;
    }
    
    if ( ! preserveUnitID ) {
        components.unitID = NSIntegerMax;
    }
    
    components.controlSpecifier = nil;
    
    return [XkeysIdentifiers identifierFromComponents:components];
}

// MARK: - XkeysIdentifiers internal

+ (NSString *)ledControlSpecifierWithControlIndex:(NSInteger)controlIndex {
    return [NSString stringWithFormat:@"%@:%ld", LED_CONTROL_SPECIFIER, (long)controlIndex];
}

+ (NSString *)buttonControlSpecifierWithControlIndex:(NSInteger)controlIndex {
    return [NSString stringWithFormat:@"%@:%ld", BUTTON_CONTROL_SPECIFIER, (long)controlIndex];
}

+ (NSString *)sliderControlSpecifierWithControlIndex:(NSInteger)controlIndex {
    return [NSString stringWithFormat:@"%@:%ld", SLIDER_CONTROL_SPECIFIER, (long)controlIndex];
}

+ (NSString *)outputControlSpecifierWithControlIndex:(NSInteger)controlIndex {
    return [NSString stringWithFormat:@"%@:%ld", OUTPUT_CONTROL_SPECIFIER, (long)controlIndex];
}

+ (NSString *)identifierFromComponents:(XkeysIdentifierComponents *)components {
    
    NSString *unitIDString = @"*";
    if ( components.unitID != NSIntegerMax ) {
        unitIDString = [NSString stringWithFormat:@"%ld", components.unitID];
    }
    
    NSString *deviceIdentifier = [NSString stringWithFormat:@"%@%ld/%ld/%ld/%@", IDENTIFIER_PREFIX, FORMAT_VERSION, PIE_USB_VID, components.productID, unitIDString];
    
    if ( components.controlSpecifier == nil ) {
        return deviceIdentifier;
    }
    
    NSString *controlIdentifier = [deviceIdentifier stringByAppendingFormat:@"/%@", components.controlSpecifier];
    
    return controlIdentifier;
}

+ (XkeysIdentifierComponents *)componentsFromIdentifier:(NSString *)identifier {
    
    NSString *prefix = [IDENTIFIER_PREFIX commonPrefixWithString:identifier options:NSCaseInsensitiveSearch];
    if ( ! [prefix isEqualToString:IDENTIFIER_PREFIX] ) {
        return nil;
    }
    
    NSString *tail = [identifier substringFromIndex:IDENTIFIER_PREFIX.length];
    NSArray *stringComponents = [tail componentsSeparatedByString:@"/"];
    
    if ( stringComponents.count < 4 ) {
        return nil;
    }
    
    NSInteger identifierVersion = [stringComponents[0] integerValue];
    if ( identifierVersion != FORMAT_VERSION ) {
        return nil;
    }
    
    NSInteger vendorID = [stringComponents[1] integerValue];
    if ( vendorID != PIE_USB_VID ) {
        return nil;
    }
    
    XkeysIdentifierComponents *components = [[XkeysIdentifierComponents alloc] init];
    components.productID = [stringComponents[2] integerValue];
    
    components.model = [XkeysUnitLibrary modelFromProductID:components.productID];
    
    NSString *unitIDString = stringComponents[3];
    if ( [unitIDString isEqualToString:@"*"] ) {
        components.unitID = NSIntegerMax;
    }
    else {
        components.unitID = [unitIDString integerValue];
    }
    
    if ( stringComponents.count < 5 ) {
        return components;
    }
    
    components.controlSpecifier = stringComponents[4];
    
    return components;
}

+ (XkeysIdentifierComponents *)componentsFromUnit:(XkeysUnit<XkeysDevice> *)unit {
    
    XkeysIdentifierComponents *components = [[XkeysIdentifierComponents alloc] init];
    components.productID = unit.productID;
    components.model = unit.model;
    components.unitID = unit.unitID;
    
    return components;
}

+ (BOOL)components:(XkeysIdentifierComponents * _Nullable)components matchUnit:(XkeysUnit<XkeysDevice> *)unit {
    
    if ( components == nil ) {
        return NO;
    }
    
    if ( XkeysIdentifiersRequireProductIDMatch ) {
        
        if ( components.productID != unit.productID ) {
            return NO;
        }
    }
    else {
        
        if ( components.model != unit.model ) {
            return NO;
        }
    }
    
    if ( components.unitID == NSIntegerMax ) {
        return YES;
    }
    
    if ( ! XkeysIdentifiersRequireUnitIDMatch ) {
        return YES;
    }
    
    return ( components.unitID == unit.unitID );
}

@end
