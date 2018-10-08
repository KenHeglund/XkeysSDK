//
//  XkeysLEDOutput.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysIdentifiers.h"

#import "XkeysLEDOutput.h"

@implementation XkeysLEDOutput

@synthesize color = _color;

- (instancetype)initWithDevice:(XkeysUnit<XkeysDevice> *)device color:(XkeysLEDColor)color controlIndex:(NSInteger)controlIndex {
    
    NSString *nameFormat = NSLocalizedString(@"%@ LED", @"Format for the name of an LED indicating its color such as 'Red LED'");
    NSString *name = [NSString stringWithFormat:nameFormat, [XkeysLEDOutput nameForColor:color]];
    
    self = [super initWithDevice:device name:name controlIndex:controlIndex];
    if ( ! self ) {
        return nil;
    }
    
    _color = color;
    
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ <%p>: %@ \"%@\"", NSStringFromClass([self class]), self, self.identifier, self.name];
}

- (NSString *)identifier {
    return [XkeysIdentifiers identifierForLED:self];
}

- (XkeysLEDState)state {
    return self.ledState;
}

- (void)setState:(XkeysLEDState)newValue {
    
    self.ledState = newValue;
    
    void (^callback)(XkeysLEDState) = self.onStateChange;
    if ( callback == NULL ) {
        return;
    }
    
    callback(newValue);
}

+ (NSString *)nameForColor:(XkeysLEDColor)color {
    
    switch ( color ) {
        case XkeysLEDColorRed:
            return NSLocalizedString(@"Red", @"The color red as used to describe a colored LED such as 'Red LED'");
        case XkeysLEDColorBlue:
            return NSLocalizedString(@"Blue", @"The color blue as used to describe a colored LED such as 'Blue LED'");
        case XkeysLEDColorGreen:
            return NSLocalizedString(@"Green", @"The color green as used to describe a colored LED such as 'Green LED'");
    }
}

@end
