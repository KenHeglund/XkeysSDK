//
//  XkeysDeviceView.h
//  XkeysViewer
//
//  Provides basic drawing for the state of an Xkeys device.
//
//  Created by Ken Heglund on 11/6/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import Cocoa;

@class XkeysState;

extern const CGFloat XkeysDeviceViewOutlineThickness;

typedef NS_ENUM(NSInteger, XkeysDeviceBorderStyle) {
    XkeysDeviceBorderStyleNone = 0,
    XkeysDeviceBorderStyleLeftRight,
    XkeysDeviceBorderStyleTopBottom,
};

NS_ASSUME_NONNULL_BEGIN

@interface XkeysDeviceView : NSView

@property (nonatomic, nullable) XkeysState *deviceState;
@property (nonatomic, readonly) NSPoint cursorLocation;

+ (XkeysDeviceBorderStyle)borderStyle;

+ (NSInteger)buttonColumnCount;
+ (NSInteger)buttonRowCount;
+ (NSInteger)buttonNumbersPerColumn;

+ (BOOL)hasBacklitButtons;

+ (NSRect)calculateDeviceFrameWithinBounds:(NSRect)viewBounds;
+ (NSRect)calculateControlFrameInDevice:(NSRect)deviceFrame;
+ (NSRect)calculateButtonFrame:(NSInteger)buttonNumber inFrame:(NSRect)controlFrame;

+ (NSImage *)imageForButtonNumber:(NSInteger)buttonNumber;

+ (void)drawButtonNumber:(NSImage *)numberImage inFrame:(NSRect)frame withFraction:(CGFloat)fraction;

+ (NSInteger)effectiveColumnCount;
+ (NSInteger)effectiveRowCount;

- (NSInteger)buttonNumberAtLocation:(NSPoint)locationInView inFrame:(NSRect)controlFrame;

- (void)mouseDownInEdgeAtLocation:(NSPoint)locationInView;

- (void)invalidateLEDs;
- (void)invalidateButtonNumber:(NSInteger)buttonNumber;

- (void)drawControlOverlayInFrame:(NSRect)controlFrame;
- (void)drawEdgeOverlayInFrame:(NSRect)deviceFrame;

@end

NS_ASSUME_NONNULL_END
