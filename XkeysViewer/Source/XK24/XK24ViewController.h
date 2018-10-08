//
//  XK24ViewController.h
//  XkeysViewer
//
//  Coordinates the UI for an XK-24 with PID #1 (1029) or #3 (1027).
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XkeysDeviceViewController.h"

@class XK24State, XK24View;
@protocol Xkeys24;

NS_ASSUME_NONNULL_BEGIN

@interface XK24ViewController : XkeysDeviceViewController

@property (nonatomic, readonly) id<Xkeys24> xkeys24Device;
@property (nonatomic, readonly) XK24State *xkeys24State;
@property (nonatomic, readonly) XK24View *xkeys24View;

- (instancetype)initWithXkeysDevice:(id<XkeysDevice>)xkeysDevice NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSNibName _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil xkeysDevice:(id<XkeysDevice>)xkeysDevice NS_UNAVAILABLE;

@end

// MARK: -

@interface XK24HWModeViewController : XK24ViewController

@end

NS_ASSUME_NONNULL_END
