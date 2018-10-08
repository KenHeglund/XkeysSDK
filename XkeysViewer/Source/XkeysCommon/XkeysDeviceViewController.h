//
//  XkeysDeviceViewController.h
//  XkeysViewer
//
//  Matches an XkeysDevice instance to a device-specific view controller to handle its UI, and acts as a common base class to such view controllers.
//
//  Created by Ken Heglund on 10/30/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Cocoa;

@class XkeysState, XkeysDeviceView;
@protocol XkeysDevice;

NS_ASSUME_NONNULL_BEGIN

@interface XkeysDeviceViewController : NSViewController

@property (nonatomic, readonly) NSTextField *unitIDTextField;

@property (nonatomic) IBOutlet XkeysDeviceView *xkeysView;
@property (nonatomic, readonly) id<XkeysDevice> xkeysDevice;
@property (nonatomic, readonly) XkeysState *xkeysState;

+ (NSViewController * _Nullable)viewControllerForXkeysDevice:(id<XkeysDevice>)xkeysDevice;

- (instancetype)initWithNibName:(NSNibName _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil xkeysDevice:(id<XkeysDevice>)xkeysDevice NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSNibName _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (XkeysState *)createDeviceState;
- (void)initializeDeviceState;
- (void)initializeDeviceCallbacks;

@end

NS_ASSUME_NONNULL_END
