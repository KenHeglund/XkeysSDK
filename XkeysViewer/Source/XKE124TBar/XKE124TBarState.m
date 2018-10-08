//
//  XKE124TBarState.m
//  XkeysViewer
//
//  Created by Ken Heglund on 10/24/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XKE124TBarState.h"

static const NSInteger TBAR_POSITION_MIN = 0;
static const NSInteger TBAR_POSITION_MAX = 255;

// MARK: -

@implementation XKE124TBarState

- (instancetype)init {
    
    self = [super initWithButtonCount:128];
    if ( ! self ) {
        return nil;
    }
    
    _currentTbarPosition = 0;
    
    return self;
}

- (NSInteger)minTbarPosition {
    return TBAR_POSITION_MIN;
}

- (NSInteger)maxTbarPosition {
    return TBAR_POSITION_MAX;
}

- (BOOL)isValidButtonNumber:(NSInteger)buttonNumber {
    
    if ( buttonNumber < self.minButtonNumber || buttonNumber > self.maxButtonNumber ) {
        return NO;
    }
    
    // On the XKE124Tbar, the T-bar occupies the 14th column of buttons in the last four rows -- button numbers 108-111
    
    return ( buttonNumber < 108 || buttonNumber > 111 );
}

@end
