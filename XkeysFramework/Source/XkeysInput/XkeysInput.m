//
//  XkeysInput.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysIdentifiers.h"
#import "XkeysUnit.h"

#import "XkeysInput.h"

@interface XkeysInput ()

@property (nonatomic, readwrite) NSInteger currentValue;
@property (nonatomic, copy, readwrite) XkeysControlCallback valueChangeCallback;

@end

// MARK: -

@implementation XkeysInput

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device cookie:(IOHIDElementCookie)cookie controlIndex:(NSInteger)controlIndex {
    
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _device = device;
    _cookie = cookie;
    _controlIndex = controlIndex;
    
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ <%p>: %@", NSStringFromClass([self class]), self, self.identifier];
}

// MARK: - XkeysControl implementation

- (XkeysControlIdentifier)identifier {
    return [XkeysIdentifiers identifierForInput:self];
}

- (NSString *)name {
    NSAssert(NO, @"A subclass of XkeysInput should provide a type-specific name");
    return @"Xkeys Control";
}

- (NSInteger)minimumValue {
    NSAssert(NO, @"A subclass of XkeysInput should provide its minimum value");
    return 0;
}

- (NSInteger)maximumValue {
    NSAssert(NO, @"A subclass of XkeysInput should provide its maximum value");
    return 1;
}

- (XkeysInputType)type {
    NSAssert(NO, @"A subclass of XkeysInput should provide its specific type");
    return XkeysInputTypeButton;
}

- (void)onValueChangePerform:(XkeysControlCallback _Nullable)callback {
    self.valueChangeCallback = callback;
}

- (BOOL)matchesIdentifier:(XkeysControlIdentifier)identifier {
    return [XkeysIdentifiers identifier:identifier matchesInput:self];
}

// MARK: - XkeysInput implementation

- (BOOL)handleInputValue:(CFIndex)value {
    
    if ( self.currentValue == value ) {
        return NO;
    }
    
    self.currentValue = value;
    
    XkeysControlCallback callback = self.valueChangeCallback;
    if ( callback == NULL ) {
        return YES;
    }
    
    if ( ! callback(self) ) {
        self.valueChangeCallback = NULL;
    }
    
    return YES;
}

@end
