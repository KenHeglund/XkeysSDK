//
//  XKE124TBarViewController.h
//  XkeysViewer
//
//  Coordinates the UI for an XKE-124 T-bar with PID #1 (1275) or #4 (1278).
//
//  Created by Ken Heglund on 10/24/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysDeviceViewController.h"

@class XKE124TBarState, XKE124TBarView;
@protocol Xkeys124Tbar;

NS_ASSUME_NONNULL_BEGIN

@interface XKE124TBarViewController : XkeysDeviceViewController

@property (nonatomic, readonly) id<Xkeys124Tbar> xkeys124Device;
@property (nonatomic, readonly) XKE124TBarState *xkeys124State;
@property (nonatomic, readonly) XKE124TBarView *xkeys124View;

- (instancetype)initWithXkeysDevice:(id<XkeysDevice>)xkeysDevice NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSNibName _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil xkeysDevice:(id<XkeysDevice>)xkeysDevice NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
