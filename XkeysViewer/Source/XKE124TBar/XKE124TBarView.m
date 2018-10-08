//
//  XKE124TBarView.m
//  XkeysViewer
//
//  Created by Ken Heglund on 10/24/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XKE124TBarState.h"

#import "XKE124TBarView.h"

@implementation XKE124TBarView

// MARK: - XkeysDeviceView overrides

+ (NSInteger)buttonColumnCount {
    return 16;
}

+ (NSInteger)buttonRowCount {
    return 8;
}

- (NSInteger)buttonNumberAtLocation:(NSPoint)locationInView inFrame:(NSRect)controlFrame {
    
    NSInteger buttonNumber = [super buttonNumberAtLocation:locationInView inFrame:controlFrame];
    
    if ( ![self.deviceState isValidButtonNumber:buttonNumber] ) {
        return NSNotFound;
    }
    
    return buttonNumber;
}

- (void)drawControlOverlayInFrame:(NSRect)controlFrame {
    
    XKE124TBarState *tbarState = (XKE124TBarState *)self.deviceState;
    NSAssert([tbarState isKindOfClass:[XKE124TBarState class]], @"");
    
    [[self class] drawTbarState:tbarState inFrame:controlFrame];
}

// MARK: - XKE124TBarView implementation

- (void)invalidateTbar {
    
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    NSRect controlFrame = [[self class] calculateControlFrameInDevice:deviceFrame];
    NSRect tbarFrame = [XKE124TBarView calculateTbarFrameInFrame:controlFrame];
    
    [self setNeedsDisplayInRect:tbarFrame];
}

// MARK: - XKE124TBarView internal

+ (NSRect)calculateTbarFrameInFrame:(NSRect)controlFrame {
    
    // The t-bar occupies the area where buttons 108-111 would be
    
    NSRect topFrame = [[self class] calculateButtonFrame:108 inFrame:controlFrame];
    NSRect bottomFrame = [[self class] calculateButtonFrame:111 inFrame:controlFrame];
    NSRect tbarFrame = NSUnionRect(topFrame, bottomFrame);
    
    return tbarFrame;
}

+ (void)drawTbarState:(XKE124TBarState *)deviceState inFrame:(NSRect)controlFrame {
    
    NSRect tbarFrame = [XKE124TBarView calculateTbarFrameInFrame:controlFrame];
    
    [[NSColor colorWithCalibratedWhite:0.25 alpha:1.0] set];
    NSRectFill(tbarFrame);
    
    CGFloat borderOffset = XkeysDeviceViewOutlineThickness / 2.0;
    NSPoint bottomLeft = (NSPoint){ .x = NSMinX(tbarFrame) + borderOffset, .y = NSMinY(tbarFrame) };
    NSPoint topLeft = (NSPoint){ .x = NSMinX(tbarFrame) + borderOffset, .y = NSMaxY(tbarFrame) - borderOffset };
    NSPoint topRight = (NSPoint){ .x = NSMaxX(tbarFrame) - borderOffset, .y = NSMaxY(tbarFrame) - borderOffset };
    NSPoint bottomRight = (NSPoint){ .x = NSMaxX(tbarFrame) - borderOffset, .y = NSMinY(tbarFrame) };
    
    NSBezierPath *path = [[NSBezierPath alloc] init];
    path.lineWidth = XkeysDeviceViewOutlineThickness;
    [path moveToPoint:bottomLeft];
    [path lineToPoint:topLeft];
    [path lineToPoint:topRight];
    [path lineToPoint:bottomRight];
    
    [[NSColor blackColor] set];
    [path stroke];
    
    // Vertical slider slot
    
    NSRect sliderFrame = NSInsetRect(tbarFrame, tbarFrame.size.width * 0.1, tbarFrame.size.height * 0.1);
    
    const CGFloat minSlotThickness = 2.0;
    NSRect slotFrame = sliderFrame;
    slotFrame.size.width = MAX(sliderFrame.size.width * 0.1, minSlotThickness);
    slotFrame.origin.x = NSMidX(sliderFrame) - (slotFrame.size.width / 2.0);
    
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
    NSRectFill(slotFrame);
    
    // Horizontal indicator
    
    CGFloat positionAsPercent = (CGFloat)( deviceState.currentTbarPosition - deviceState.minTbarPosition ) / (CGFloat)( deviceState.maxTbarPosition - deviceState.minTbarPosition );
    
    const CGFloat minIndicatorHeight = 2.0;
    NSRect indicatorFrame = (NSRect){
        .origin.x = sliderFrame.origin.x,
        .origin.y = NSMinY(sliderFrame) + (sliderFrame.size.height * positionAsPercent),
        .size.width = sliderFrame.size.width,
        .size.height = MAX(sliderFrame.size.height * 0.05, minIndicatorHeight)
    };
    
    indicatorFrame.origin.y -= ( indicatorFrame.size.height / 2.0 );
    
    [[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] set];
    NSRectFill(indicatorFrame);
}

@end
