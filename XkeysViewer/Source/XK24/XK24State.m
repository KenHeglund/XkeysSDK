//
//  XK24State.m
//  XkeysViewer
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XK24State.h"

// MARK: -

@implementation XK24State

- (instancetype)init {
    return [super initWithButtonCount:32];
}

- (BOOL)isValidButtonNumber:(NSInteger)buttonNumber {
    
    if ( buttonNumber < self.minButtonNumber || buttonNumber > self.maxButtonNumber ) {
        return NO;
    }
    
    NSInteger rowIndex = buttonNumber % 8;
    
    return ( rowIndex <= 5 );
}

@end
