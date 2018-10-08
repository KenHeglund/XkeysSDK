//
//  XkeysBasicButton.m
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XkeysBasicButton.h"

@implementation XkeysBasicButton

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device cookie:(IOHIDElementCookie)cookie controlIndex:(NSInteger)controlIndex {
    
    self = [super initWithDevice:device cookie:cookie controlIndex:controlIndex];
    if ( ! self ) {
        return nil;
    }
    
    NSString *buttonNameFormat = NSLocalizedString(@"Button #%ld", @"The name of a numbered button such as 'Button #3'");
    _buttonName = [NSString stringWithFormat:buttonNameFormat, controlIndex];
    
    _buttonNumber = controlIndex;
    
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ \"%@\"", [super debugDescription], self.name];
}

// MARK: - XkeysControl overrides

- (NSString *)name {
    return self.buttonName;
}

- (NSInteger)minimumValue {
    return 0;
}

- (NSInteger)maximumValue {
    return 1;
}

- (XkeysInputType)type {
    return XkeysInputTypeButton;
}

@end
