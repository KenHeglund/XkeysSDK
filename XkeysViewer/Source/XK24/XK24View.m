//
//  XK24View.m
//  XkeysViewer
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import "XK24State.h"

#import "XK24View.h"

@implementation XK24View

// MARK: - XkeysDeviceView overrides

+ (XkeysDeviceBorderStyle)borderStyle {
    return XkeysDeviceBorderStyleTopBottom;
}

+ (NSInteger)buttonColumnCount {
    return 4;
}

+ (NSInteger)buttonRowCount {
    return 6;
}

- (void)drawEdgeOverlayInFrame:(NSRect)deviceFrame {
    
    // Overridden to draw the programming switch
    
    XK24State *xkeys24State = (XK24State *)self.deviceState;
    NSAssert([xkeys24State isKindOfClass:[XK24State class]], @"");
    if ( ! [xkeys24State isKindOfClass:[XK24State class]] ) {
        return;
    }
    
    NSRect switchFrame = [[self class] calculateProgrammingSwitchFrameInDevice:deviceFrame];
    NSBezierPath *switchFramePath = [NSBezierPath bezierPathWithOvalInRect:switchFrame];
    
    if ( xkeys24State.programmingSwitch ) {
        [[NSColor grayColor] set];
    }
    else {
        [[NSColor lightGrayColor] set];
    }
    
    [switchFramePath fill];
    
    const CGFloat minLineWidth = 1.0;
    switchFramePath.lineWidth = MAX(XkeysDeviceViewOutlineThickness * 0.5, minLineWidth);
    
    [[NSColor blackColor] set];
    [switchFramePath stroke];
    
    if ( ! xkeys24State.programmingSwitch ) {
        return;
    }
    
    const CGFloat dotInsetFraction = 0.35;
    CGFloat inset = switchFrame.size.height * dotInsetFraction;
    NSRect dotFrame = NSInsetRect(switchFrame, inset, inset);
    
    [[NSColor darkGrayColor] set];
    [[NSBezierPath bezierPathWithOvalInRect:dotFrame] fill];
}

// MARK: - XK24View implementation

- (void)invalidateProgrammingSwitch {
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    NSRect switchFrame = [[self class] calculateProgrammingSwitchFrameInDevice:deviceFrame];
    [self setNeedsDisplayInRect:switchFrame];
}

// MARK: - XK24View internal

+ (NSRect)calculateProgrammingSwitchFrameInDevice:(NSRect)deviceFrame {
    
    const CGFloat effectiveRowCount = 8.0;
    
    CGFloat frameHeight = deviceFrame.size.height / effectiveRowCount / 2.0;
    NSRect switchFrame = (NSRect){
        .origin.x = NSMidX(deviceFrame) - ( frameHeight * 0.5 ),
        .origin.y = NSMaxY(deviceFrame) - ( frameHeight * 1.5 ),
        .size.width = frameHeight,
        .size.height = frameHeight
    };
    
    return switchFrame;
}

@end
