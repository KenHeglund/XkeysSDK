//
//  XKE124TBarState.h
//  XkeysViewer
//
//  Encapsulates the state of an XKE-124 T-bar.  Extends XKeysState to include T-bar state.
//
//  Created by Ken Heglund on 10/24/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Foundation;

#import "XkeysState.h"

@interface XKE124TBarState : XkeysState

@property (nonatomic) NSInteger currentTbarPosition;

@property (nonatomic, readonly) NSInteger minTbarPosition;
@property (nonatomic, readonly) NSInteger maxTbarPosition;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithButtonCount:(NSInteger)numberOfButtons NS_UNAVAILABLE;

@end
