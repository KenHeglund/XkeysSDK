//
//  XK24State.h
//  XkeysViewer
//
//  Encapsulates the state of an XK-24.
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import "XkeysState.h"

@interface XK24State : XkeysState

@property (nonatomic) BOOL programmingSwitch;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithButtonCount:(NSInteger)numberOfButtons NS_UNAVAILABLE;

@end
