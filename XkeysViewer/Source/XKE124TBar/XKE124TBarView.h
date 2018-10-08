//
//  XKE124TBarView.h
//  XkeysViewer
//
//  Provides drawing specific to the XKE-124 T-bar.
//
//  Created by Ken Heglund on 10/24/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Cocoa;

#import "XkeysDeviceView.h"

@interface XKE124TBarView : XkeysDeviceView

- (void)invalidateTbar;

@end
