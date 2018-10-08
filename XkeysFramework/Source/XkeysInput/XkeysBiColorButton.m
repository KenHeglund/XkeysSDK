//
//  XkeysBiColorButton.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysBiColorButton.h"

@implementation XkeysBiColorButton

- (NSString *)debugDescription {
    
    NSMutableString *description = [[super debugDescription] mutableCopy];
    
    [description appendFormat:@"\n    %@", [self.blueLED debugDescription]];
    [description appendFormat:@"\n    %@", [self.redLED debugDescription]];
    
    return description;
}

@end
