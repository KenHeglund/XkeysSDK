//
//  XkeysDeviceView.m
//  XkeysViewer
//
//  Created by Ken Heglund on 11/6/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import "XkeysState.h"

#import "XkeysDeviceView.h"

const CGFloat XkeysDeviceViewOutlineThickness = 2.0;

// MARK: -

@interface XkeysDeviceView ()

@property (nonatomic, nullable) NSTrackingArea *trackingArea;
@property (nonatomic, readwrite) NSPoint cursorLocation;

+ (NSInteger)effectiveColumnCount;
+ (NSInteger)effectiveRowCount;

@end

// MARK: -

@implementation XkeysDeviceView

// MARK: - NSView overrides

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    
    [super viewWillMoveToWindow:newWindow];
    
    if ( self.trackingArea ) {
        [self removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
}

- (void)viewDidMoveToWindow {
    
    [super viewDidMoveToWindow];
    
    NSTrackingAreaOptions options = ( NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect );
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:options owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    if ( NSIsEmptyRect(dirtyRect) ) {
        return;
    }
    
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    NSRect controlFrame = [[self class] calculateControlFrameInDevice:deviceFrame];
    
    [self drawButtonStateInFrame:controlFrame];
    [self drawButtonGridInFrame:controlFrame];
    [self drawControlOverlayInFrame:controlFrame];
    [self drawEdgeStateInFrame:deviceFrame];
    [self drawEdgeOverlayInFrame:deviceFrame];
}

// MARK: - NSResponder overrides

- (void)mouseEntered:(NSEvent *)event {
    self.cursorLocation = [self convertPoint:event.locationInWindow fromView:nil];
    [self invalidateDisplayAtLocation:self.cursorLocation];
}

- (void)mouseMoved:(NSEvent *)event {
    [self invalidateDisplayAtLocation:self.cursorLocation];
    self.cursorLocation = [self convertPoint:event.locationInWindow fromView:nil];
    [self invalidateDisplayAtLocation:self.cursorLocation];
}

- (void)mouseExited:(NSEvent *)event {
    [self invalidateDisplayAtLocation:self.cursorLocation];
    self.cursorLocation = NSZeroPoint;
}

- (void)mouseDown:(NSEvent *)event {
    
    NSPoint locationInView = [self convertPoint:event.locationInWindow fromView:nil];
    
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    NSRect controlFrame = [[self class] calculateControlFrameInDevice:deviceFrame];
    
    NSRect edgeFrame = NSZeroRect;
    
    XkeysDeviceBorderStyle borderStyle = [[self class] borderStyle];
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
        edgeFrame = [[self class] calculateLeftEdgeFrameInDevice:deviceFrame];
    }
    else if ( borderStyle == XkeysDeviceBorderStyleTopBottom ) {
        edgeFrame = [[self class] calculateTopEdgeFrameInDevice:deviceFrame];
    }
    
    if ( NSPointInRect(locationInView, controlFrame) ) {
        
        if ( ! [[self class] hasBacklitButtons] ) {
            return;
        }
        
        NSInteger buttonNumber = [self buttonNumberAtLocation:locationInView inFrame:controlFrame];
        
        if ( buttonNumber != NSNotFound ) {
            
            NSRect buttonFrame = [[self class] calculateButtonFrame:buttonNumber inFrame:controlFrame];
            NSRect blueFrame = [[self class] calculateBacklightFrame:XkeysLEDColorBlue inFrame:buttonFrame];
            NSRect redFrame = [[self class] calculateBacklightFrame:XkeysLEDColorRed inFrame:buttonFrame];
            
            CGFloat additionalCursorMargin = ( NSMinY(blueFrame) - NSMaxY(redFrame) ) / 2.0;
            
            NSRect blueCursorFrame = NSInsetRect(blueFrame, -additionalCursorMargin, -additionalCursorMargin);
            NSRect redCursorFrame = NSInsetRect(redFrame, -additionalCursorMargin, -additionalCursorMargin);
            
            if ( NSPointInRect(locationInView, blueCursorFrame) ) {
                BOOL backlightIsOn = [self.deviceState isBlueBacklightOfButtonOn:buttonNumber];
                [self.deviceState setBlueBacklightOn:!backlightIsOn ofButton:buttonNumber];
                [self setNeedsDisplayInRect:buttonFrame];
            }
            else if ( NSPointInRect(locationInView, redCursorFrame) ) {
                BOOL backlightIsOn = [self.deviceState isRedBacklightOfButtonOn:buttonNumber];
                [self.deviceState setRedBacklightOn:!backlightIsOn ofButton:buttonNumber];
                [self setNeedsDisplayInRect:buttonFrame];
            }
        }
    }
    else if ( NSPointInRect(locationInView, edgeFrame) ) {
        
        NSRect greenFrame = [[self class] calculateLEDFrame:XkeysLEDColorGreen inEdge:edgeFrame];
        NSRect redFrame = [[self class] calculateLEDFrame:XkeysLEDColorRed inEdge:edgeFrame];
        
        CGFloat additionalCursorMargin = ( NSMinY(greenFrame) - NSMaxY(redFrame) ) / 2.0;
        
        NSRect greenCursorFrame = NSInsetRect(greenFrame, -additionalCursorMargin, -additionalCursorMargin);
        NSRect redCursorFrame = NSInsetRect(redFrame, -additionalCursorMargin, -additionalCursorMargin);
        
        if ( NSPointInRect(locationInView, greenCursorFrame) ) {
            self.deviceState.greenLED = !self.deviceState.greenLED;
            [self setNeedsDisplayInRect:greenFrame];
        }
        else if ( NSPointInRect(locationInView, redCursorFrame) ) {
            self.deviceState.redLED = !self.deviceState.redLED;
            [self setNeedsDisplayInRect:redFrame];
        }
        
        [self mouseDownInEdgeAtLocation:locationInView];
    }
}

// MARK: - XkeysDeviceView implementation

+ (XkeysDeviceBorderStyle)borderStyle {
    return XkeysDeviceBorderStyleLeftRight;
}

+ (NSInteger)buttonColumnCount {
    return 1;
}

+ (NSInteger)buttonRowCount {
    return 1;
}

+ (NSInteger)buttonNumbersPerColumn {
    return 8;
}

+ (BOOL)hasBacklitButtons {
    return YES;
}

+ (NSRect)calculateDeviceFrameWithinBounds:(NSRect)viewBounds {
    
    /*
     The device is drawn in a rectangle concentric with the view bounds.
     The buttons are square.
     The area occupied by the left and right sides of the device are each equal in width to a column of buttons.
     */
    
    NSRect frameExcludingOutline = NSInsetRect(viewBounds, XkeysDeviceViewOutlineThickness, XkeysDeviceViewOutlineThickness);
    
    const CGFloat aspectRatio = (CGFloat)[self effectiveColumnCount] / (CGFloat)[self effectiveRowCount];
    
    CGFloat deviceWidth = MIN(frameExcludingOutline.size.height * aspectRatio, frameExcludingOutline.size.width);
    CGFloat deviceHeight = deviceWidth / aspectRatio;
    
    NSRect centeredDeviceFrame = (NSRect){
        .origin.x = NSMidX(viewBounds) - (deviceWidth / 2.0),
        .origin.y = NSMidY(viewBounds) - (deviceHeight / 2.0),
        .size.width = deviceWidth,
        .size.height = deviceHeight
    };
    
    return ( NSInsetRect(centeredDeviceFrame, -XkeysDeviceViewOutlineThickness, -XkeysDeviceViewOutlineThickness) );
}

+ (NSRect)calculateControlFrameInDevice:(NSRect)deviceFrame {
    
    // The control frame is the area that contains the physical controls
    
    NSRect frameExcludingOutline = NSInsetRect(deviceFrame, XkeysDeviceViewOutlineThickness, XkeysDeviceViewOutlineThickness);
    
    CGFloat buttonColumnCount = (CGFloat)[self buttonColumnCount];
    CGFloat effectiveColumnCount = (CGFloat)[self effectiveColumnCount];
    CGFloat buttonRowCount = (CGFloat)[self buttonRowCount];
    CGFloat effectiveRowCount = (CGFloat)[self effectiveRowCount];
    
    CGFloat leftEdgeWidth = (frameExcludingOutline.size.width / effectiveColumnCount) * ( (effectiveColumnCount - buttonColumnCount) / 2.0 );
    CGFloat bottomEdgeWidth = (frameExcludingOutline.size.height / effectiveRowCount) * ( (effectiveRowCount - buttonRowCount) / 2.0 );
    
    NSRect controlFrame = (NSRect){
        .origin.x = NSMinX(frameExcludingOutline) + leftEdgeWidth,
        .origin.y = NSMinY(frameExcludingOutline) + bottomEdgeWidth,
        .size.width = frameExcludingOutline.size.width * buttonColumnCount / effectiveColumnCount,
        .size.height = frameExcludingOutline.size.height * buttonRowCount / effectiveRowCount
    };
    
    return ( controlFrame );
}

+ (NSRect)calculateLeftEdgeFrameInDevice:(NSRect)deviceFrame {
    
    // The left edge area contains the green and red LEDs for devices with a left/right border style
    
    NSRect frameExcludingOutline = NSInsetRect(deviceFrame, XkeysDeviceViewOutlineThickness, XkeysDeviceViewOutlineThickness);
    
    CGFloat edgeWidth = 0.0;
    
    if ( [self borderStyle] == XkeysDeviceBorderStyleLeftRight ) {
        edgeWidth = frameExcludingOutline.size.width / (CGFloat)[self effectiveColumnCount];
    }
    
    NSRect leftEdgeFrame = (NSRect){
        .origin = frameExcludingOutline.origin,
        .size.width = edgeWidth,
        .size.height = frameExcludingOutline.size.height
    };
    
    return ( leftEdgeFrame );
}

+ (NSRect)calculateTopEdgeFrameInDevice:(NSRect)deviceFrame {
    
    // The top edge area contains green and red LEDs for devices with a top/bottom border style
    
    NSRect frameExcludingOutline = NSInsetRect(deviceFrame, XkeysDeviceViewOutlineThickness, XkeysDeviceViewOutlineThickness);
    
    CGFloat edgeHeight = 0.0;
    
    if ( [self borderStyle] == XkeysDeviceBorderStyleTopBottom ) {
        edgeHeight = frameExcludingOutline.size.height / (CGFloat)[self effectiveRowCount];
    }
    
    NSRect topEdgeFrame = (NSRect){
        .origin.x = frameExcludingOutline.origin.x,
        .origin.y = NSMaxY(frameExcludingOutline) - edgeHeight,
        .size.width = frameExcludingOutline.size.width,
        .size.height = edgeHeight
    };
    
    return ( topEdgeFrame );
}

+ (NSRect)calculateButtonFrame:(NSInteger)buttonNumber inFrame:(NSRect)controlFrame {
    
    NSSize buttonSize = (NSSize){
        .width = controlFrame.size.width / (CGFloat)[self buttonColumnCount],
        .height = controlFrame.size.height / (CGFloat)[self buttonRowCount]
    };
    
    NSInteger rowIndex = (buttonNumber % [self buttonNumbersPerColumn]);
    NSInteger columnIndex = (buttonNumber / [self buttonNumbersPerColumn]);
    
    NSRect buttonFrame = (NSRect){
        .origin.x = NSMinX(controlFrame) + (buttonSize.width * columnIndex),
        .origin.y = NSMaxY(controlFrame) - (buttonSize.height * (rowIndex + 1) ),
        .size = buttonSize
    };
    
    return ( buttonFrame );
}

+ (NSRect)calculateBacklightFrame:(XkeysLEDColor)backlight inFrame:(NSRect)buttonFrame {
    
    const CGFloat minBacklightMargin = 1.0;
    CGFloat backlightMargin = MAX(buttonFrame.size.width * 0.1, minBacklightMargin);
    NSRect backlightFrame = NSInsetRect(buttonFrame, backlightMargin, backlightMargin);
    CGFloat ledHeight = (backlightFrame.size.height - backlightMargin) / 2.0;
    
    NSRect ledFrame = (NSRect){
        .origin.x = NSMinX(backlightFrame),
        .origin.y = NSMinY(backlightFrame),
        .size.width = backlightFrame.size.width,
        .size.height = ledHeight
    };
    
    if ( backlight == XkeysLEDColorBlue ) {
        ledFrame.origin.y = NSMaxY(backlightFrame) - ledHeight;
    }
    
    return ( ledFrame );
}

+ (NSRect)calculateLEDFrame:(XkeysLEDColor)led inEdge:(NSRect)edgeFrame {
    
    XkeysDeviceBorderStyle borderStyle = [self borderStyle];
    
    NSRect frameExcludingBorder = edgeFrame;
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
        frameExcludingBorder.size.width -= XkeysDeviceViewOutlineThickness;
    }
    else {
        frameExcludingBorder.size.height -= XkeysDeviceViewOutlineThickness;
        frameExcludingBorder.origin.y += XkeysDeviceViewOutlineThickness;
    }
    
    CGFloat maxAvailableSize = MIN(frameExcludingBorder.size.width, frameExcludingBorder.size.height);
    
    const CGFloat minLEDInset = 1.0;
    CGFloat ledSpacing = MAX(maxAvailableSize * 0.1, minLEDInset);
    
    NSRect ledArea = NSInsetRect(frameExcludingBorder, ledSpacing, ledSpacing);
    CGFloat ledSize = MIN(ledArea.size.width, ledArea.size.height);
    ledArea.size.width = ledSize;
    ledArea.size.height = ledSize;
    
    const CGFloat ledLeadingSpacingMultiple = 3.0;
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
        ledArea.origin.y = NSMaxY(frameExcludingBorder) - ( ledLeadingSpacingMultiple * ledSpacing ) - ledSize;
    }
    else {
        ledArea.origin.x = NSMinX(frameExcludingBorder) + ( ledLeadingSpacingMultiple * ledSpacing );
    }
    
    CGFloat ledHeight = ledSize * 0.45;
    
    NSRect ledFrame = (NSRect){
        .origin.x = NSMinX(ledArea),
        .origin.y = NSMaxY(ledArea) - ledHeight,
        .size.width = ledArea.size.width,
        .size.height = ledHeight
    };
    
    if ( led == XkeysLEDColorRed ) {
        ledFrame.origin.y = NSMaxY(ledArea) - (ledHeight * 2.0) - ledSpacing;
    }
    
    return ( ledFrame );
}

+ (NSImage *)imageForButtonNumber:(NSInteger)buttonNumber {
    
    // Button numbers are cached as images because rendering text is really expensive
    
    static NSMutableDictionary<NSNumber *, NSImage *> *imageCache = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSMutableDictionary alloc] init];
    });
    
    NSImage *numberImage = imageCache[@(buttonNumber)];
    if ( numberImage != nil ) {
        return ( numberImage );
    }
    
    NSDictionary *attributes = @{
        NSFontAttributeName : [NSFont systemFontOfSize:96.0],
        NSForegroundColorAttributeName : [NSColor blackColor],
    };
    
    NSString *numberText = [NSString stringWithFormat:@"%ld", buttonNumber];
    NSSize textSize = [numberText sizeWithAttributes:attributes];
    
    numberImage = [[NSImage alloc] initWithSize:textSize];
    [numberImage lockFocus];
    {
        [numberText drawAtPoint:NSZeroPoint withAttributes:attributes];
    }
    [numberImage unlockFocus];
    
    imageCache[@(buttonNumber)] = numberImage;
    
    return ( numberImage );
}

+ (void)drawButtonNumber:(NSImage *)numberImage inFrame:(NSRect)frame withFraction:(CGFloat)fraction {
    
    CGFloat textHeightLimit = frame.size.height * 0.5;
    CGFloat textWidthLimit = frame.size.width * 0.75;
    
    CGFloat verticalScale = textHeightLimit / numberImage.size.height;
    CGFloat horizontalScale = textWidthLimit / numberImage.size.width;
    
    // Prefer that the vertical scale is used, the result will be numbers all drawn with the same height.
    CGFloat drawScale = MIN(verticalScale, horizontalScale);
    
    NSSize drawSize = (NSSize){
        .width = numberImage.size.width * drawScale,
        .height = numberImage.size.height * drawScale,
    };
    
    NSRect drawRect = (NSRect){
        .origin.x = NSMidX(frame) - (drawSize.width / 2.0),
        .origin.y = NSMidY(frame) - (drawSize.height / 2.0),
        .size = drawSize
    };
    
    [numberImage drawInRect:drawRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:fraction];
}

+ (NSInteger)effectiveColumnCount {
    
    if ( [self borderStyle] == XkeysDeviceBorderStyleLeftRight ) {
        return ( [self buttonColumnCount] + 2 );
    }
    
    return [self buttonColumnCount];
}

+ (NSInteger)effectiveRowCount {
    
    if ( [self borderStyle] == XkeysDeviceBorderStyleTopBottom ) {
        return ( [self buttonRowCount] + 2 );
    }
    
    return [self buttonRowCount];
}

- (NSInteger)buttonNumberAtLocation:(NSPoint)locationInView inFrame:(NSRect)controlFrame {
    
    CGFloat rowHeight = controlFrame.size.height / (CGFloat)[[self class] buttonRowCount];
    const NSInteger maxRowIndex = [[self class] buttonRowCount] - 1;
    NSInteger rowIndex = MIN(maxRowIndex - (NSInteger)floor((locationInView.y - NSMinY(controlFrame)) / rowHeight), maxRowIndex);
    
    CGFloat columnWidth = controlFrame.size.width / (CGFloat)[[self class] buttonColumnCount];
    NSInteger maxColumnIndex = [[self class] buttonColumnCount] - 1;
    NSInteger columnIndex = MIN((NSInteger)floor((locationInView.x - NSMinX(controlFrame)) / columnWidth), maxColumnIndex);
    
    NSInteger buttonNumber = (columnIndex * [[self class] buttonNumbersPerColumn]) + rowIndex;
    
    return ( buttonNumber );
}

- (void)mouseDownInEdgeAtLocation:(NSPoint)locationInView {
    // Hook for subclasses to handle additional mouseDown events
}

- (void)invalidateDisplayAtLocation:(NSPoint)locationInView {
    
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    NSRect controlFrame = [[self class] calculateControlFrameInDevice:deviceFrame];
    XkeysDeviceBorderStyle borderStyle = [[self class] borderStyle];
    
    NSRect edgeFrame = NSZeroRect;
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
        edgeFrame = [[self class] calculateLeftEdgeFrameInDevice:deviceFrame];
    }
    else if ( borderStyle == XkeysDeviceBorderStyleTopBottom ) {
        edgeFrame = [[self class] calculateTopEdgeFrameInDevice:deviceFrame];
    }
    
    if ( NSPointInRect(locationInView, controlFrame) ) {
        
        NSInteger buttonNumber = [self buttonNumberAtLocation:locationInView inFrame:controlFrame];
        if ( buttonNumber == NSNotFound ) {
            return;
        }
        
        NSRect buttonFrame = [[self class] calculateButtonFrame:buttonNumber inFrame:controlFrame];
        
        [self setNeedsDisplayInRect:buttonFrame];
    }
    else if ( NSPointInRect(locationInView, edgeFrame) ) {
        
        [self setNeedsDisplayInRect:edgeFrame];
    }
}

- (void)invalidateLEDs {
    
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    XkeysDeviceBorderStyle borderStyle = [[self class] borderStyle];
    
    NSRect edgeFrame = NSZeroRect;
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
        edgeFrame = [[self class] calculateLeftEdgeFrameInDevice:deviceFrame];
    }
    else if ( borderStyle == XkeysDeviceBorderStyleTopBottom ) {
        edgeFrame = [[self class] calculateTopEdgeFrameInDevice:deviceFrame];
    }
    
    NSRect greenLEDFrame = [[self class] calculateLEDFrame:XkeysLEDColorGreen inEdge:edgeFrame];
    [self setNeedsDisplayInRect:greenLEDFrame];
    
    NSRect redLEDFrame = [[self class] calculateLEDFrame:XkeysLEDColorRed inEdge:edgeFrame];
    [self setNeedsDisplayInRect:redLEDFrame];
}

- (void)invalidateButtonNumber:(NSInteger)buttonNumber {
    
    NSRect deviceFrame = [[self class] calculateDeviceFrameWithinBounds:self.bounds];
    NSRect controlFrame = [[self class] calculateControlFrameInDevice:deviceFrame];
    
    [self setNeedsDisplayInRect:[[self class] calculateButtonFrame:buttonNumber inFrame:controlFrame]];
}

- (void)drawButtonStateInFrame:(NSRect)controlFrame {
    
    XkeysState *deviceState = self.deviceState;
    NSPoint cursorLocation = self.cursorLocation;
    
    for ( NSInteger buttonNumber = deviceState.minButtonNumber ; buttonNumber <= deviceState.maxButtonNumber ; buttonNumber += 1 ) {
        
        if ( ! [deviceState isValidButtonNumber:buttonNumber] ) {
            continue;
        }
        
        NSRect buttonFrame = [[self class] calculateButtonFrame:buttonNumber inFrame:controlFrame];
        NSRect blueFrame = [[self class] calculateBacklightFrame:XkeysLEDColorBlue inFrame:buttonFrame];
        NSRect redFrame = [[self class] calculateBacklightFrame:XkeysLEDColorRed inFrame:buttonFrame];
        
        const CGFloat maxAdditionalMargin = 2.0;
        CGFloat additionalCursorMargin = MIN(( NSMinY(blueFrame) - NSMaxY(redFrame) ) / 2.0, maxAdditionalMargin);
        NSRect blueCursorFrame = NSInsetRect(blueFrame, -additionalCursorMargin, -additionalCursorMargin);
        NSRect redCursorFrame = NSInsetRect(redFrame, -additionalCursorMargin, -additionalCursorMargin);
        
        // Background
        
        NSColor *backgroundColor = [NSColor colorWithCalibratedWhite:0.90 alpha:1.0];
        
        if ( [deviceState isButtonPressed:buttonNumber] ) {
            backgroundColor = [NSColor colorWithCalibratedWhite:0.75 alpha:1.0];
        }
        
        [backgroundColor set];
        NSRectFill(buttonFrame);
        
        if ( [[self class] hasBacklitButtons] ) {
            
            // Blue backlight
            
            BOOL blueBacklightIsOn = [deviceState isBlueBacklightOfButtonOn:buttonNumber];
            
            if ( blueBacklightIsOn ) {
                [[NSColor colorWithCalibratedRed:0.0 green:0.55 blue:1.0 alpha:1.0] set];
                NSRectFill(blueFrame);
            }
            
            if ( blueBacklightIsOn || NSPointInRect(cursorLocation, blueCursorFrame) ) {
                [[NSColor blueColor] set];
            }
            else {
                [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.15] set];
            }
            
            NSFrameRectWithWidthUsingOperation(blueFrame, 1.0, NSCompositingOperationSourceOver);
            
            // Red backlight
            
            BOOL redBacklightIsOn = [deviceState isRedBacklightOfButtonOn:buttonNumber];
            
            if ( redBacklightIsOn ) {
                [[NSColor colorWithCalibratedRed:1.0 green:0.35 blue:0.35 alpha:1.0] set];
                NSRectFill(redFrame);
            }
            
            if ( redBacklightIsOn || NSPointInRect(cursorLocation, redCursorFrame) ) {
                [[NSColor redColor] set];
            }
            else {
                [[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.15] set];
            }
            
            NSFrameRectWithWidthUsingOperation(redFrame, 1.0, NSCompositingOperationSourceOver);
        }
        
        // Button number
        
        NSImage *numberImage = [[self class] imageForButtonNumber:buttonNumber];
        CGFloat numberImageFraction = ( NSPointInRect(cursorLocation, buttonFrame) ? 0.4 : 0.2);
        
        [[self class] drawButtonNumber:numberImage inFrame:buttonFrame withFraction:numberImageFraction];
    }
}

- (void)drawButtonGridInFrame:(NSRect)controlFrame {
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth:0.5];
    
    // Column dividers
    
    CGFloat columnWidth = controlFrame.size.width / (CGFloat)[[self class] buttonColumnCount];
    
    for ( CGFloat x = NSMinX(controlFrame) + columnWidth ; x < NSMaxX(controlFrame) ; x += columnWidth ) {
        
        NSPoint top = (NSPoint){ .x = x, .y = NSMaxY(controlFrame) };
        NSPoint bottom = (NSPoint){ .x = x, .y = NSMinY(controlFrame) };
        [NSBezierPath strokeLineFromPoint:top toPoint:bottom];
    }
    
    // Row dividers
    
    CGFloat rowHeight = controlFrame.size.height / (CGFloat)[[self class] buttonRowCount];
    
    for ( CGFloat y = NSMinY(controlFrame) + rowHeight ; y < NSMaxY(controlFrame) ; y += rowHeight ) {
        
        NSPoint left = (NSPoint){ .x = NSMinX(controlFrame), .y = y };
        NSPoint right = (NSPoint){ .x = NSMaxX(controlFrame), .y = y };
        [NSBezierPath strokeLineFromPoint:left toPoint:right];
    }
}

- (void)drawControlOverlayInFrame:(NSRect)controlFrame {
    // Hook for subclasses to draw non-button controls
}

- (void)drawEdgeStateInFrame:(NSRect)deviceFrame {
    
    XkeysState *deviceState = self.deviceState;
    NSPoint cursorLocation = self.cursorLocation;
    XkeysDeviceBorderStyle borderStyle = [[self class] borderStyle];
    
    NSRect frameExcludingOutline = NSInsetRect(deviceFrame, XkeysDeviceViewOutlineThickness, XkeysDeviceViewOutlineThickness);
    CGFloat edgeWidth = frameExcludingOutline.size.width / (CGFloat)[[self class] effectiveColumnCount];
    CGFloat edgeHeight = frameExcludingOutline.size.height / (CGFloat)[[self class] effectiveRowCount];
    
    // Blank edge
    
    NSRect blankEdgeFrame = NSZeroRect;
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
        
        blankEdgeFrame = (NSRect){
            .origin.x = NSMaxX(frameExcludingOutline) - edgeWidth,
            .origin.y = NSMinY(frameExcludingOutline),
            .size.width = edgeWidth,
            .size.height = frameExcludingOutline.size.height
        };
    }
    else if ( borderStyle == XkeysDeviceBorderStyleTopBottom ) {
        
        blankEdgeFrame = (NSRect){
            .origin = frameExcludingOutline.origin,
            .size.width = frameExcludingOutline.size.width,
            .size.height = edgeHeight
        };
    }

    [[NSColor colorWithCalibratedWhite:0.25 alpha:1.0] set];
    NSRectFill(blankEdgeFrame);
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth:XkeysDeviceViewOutlineThickness];
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
    
        NSPoint borderTop = (NSPoint){
            .x = NSMinX(blankEdgeFrame) + (XkeysDeviceViewOutlineThickness / 2.0),
            .y = NSMaxY(blankEdgeFrame)
        };
        
        NSPoint borderBottom = (NSPoint){
            .x = borderTop.x,
            .y = NSMinY(blankEdgeFrame)
        };
        
        [NSBezierPath strokeLineFromPoint:borderTop toPoint:borderBottom];
    }
    else if ( borderStyle == XkeysDeviceBorderStyleTopBottom ) {
        
        NSPoint borderLeft = (NSPoint){
            .x = NSMinX(blankEdgeFrame),
            .y = NSMaxY(blankEdgeFrame) - (XkeysDeviceViewOutlineThickness / 2.0)
        };
        
        NSPoint borderRight = (NSPoint){
            .x = NSMaxX(blankEdgeFrame),
            .y = borderLeft.y
        };
        
        [NSBezierPath strokeLineFromPoint:borderLeft toPoint:borderRight];
    }
    
    // LED edge
    
    NSRect ledEdgeFrame = NSZeroRect;
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
    
        ledEdgeFrame = (NSRect){
            .origin = frameExcludingOutline.origin,
            .size.width = edgeWidth,
            .size.height = frameExcludingOutline.size.height
        };
    }
    else if ( borderStyle ==  XkeysDeviceBorderStyleTopBottom ) {
        
        ledEdgeFrame = (NSRect){
            .origin.x = NSMinX(frameExcludingOutline),
            .origin.y = NSMaxY(frameExcludingOutline) - edgeHeight,
            .size.width = frameExcludingOutline.size.width,
            .size.height = edgeHeight
        };
    }
    
    [[NSColor colorWithCalibratedWhite:0.25 alpha:1.0] set];
    NSRectFill(ledEdgeFrame);
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth:XkeysDeviceViewOutlineThickness];
    
    if ( borderStyle == XkeysDeviceBorderStyleLeftRight ) {
    
        NSPoint borderTop = (NSPoint){
            .x = NSMaxX(ledEdgeFrame) - (XkeysDeviceViewOutlineThickness / 2.0),
            .y = NSMaxY(ledEdgeFrame) + (XkeysDeviceViewOutlineThickness / 2.0)
        };
        
        NSPoint borderBottom = (NSPoint){
            .x = borderTop.x,
            .y = NSMinY(ledEdgeFrame) - (XkeysDeviceViewOutlineThickness / 2.0)
        };
        
        [NSBezierPath strokeLineFromPoint:borderTop toPoint:borderBottom];
    }
    else if ( borderStyle == XkeysDeviceBorderStyleTopBottom ) {
        
        NSPoint borderLeft = (NSPoint){
            .x = NSMinX(ledEdgeFrame),
            .y = NSMinY(ledEdgeFrame) + (XkeysDeviceViewOutlineThickness / 2.0)
        };
        
        NSPoint borderRight = (NSPoint){
            .x = NSMaxX(ledEdgeFrame),
            .y = borderLeft.y
        };
        
        [NSBezierPath strokeLineFromPoint:borderLeft toPoint:borderRight];
    }
    
    // LEDs
    
    NSRect greenFrame = [[self class] calculateLEDFrame:XkeysLEDColorGreen inEdge:ledEdgeFrame];
    NSRect redFrame = [[self class] calculateLEDFrame:XkeysLEDColorRed inEdge:ledEdgeFrame];
    
    CGFloat additionalCursorMargin = ( NSMinY(greenFrame) - NSMaxY(redFrame) ) / 2.0;
    
    NSRect greenCursorFrame = NSInsetRect(greenFrame, -additionalCursorMargin, -additionalCursorMargin);
    NSRect redCursorFrame = NSInsetRect(redFrame, -additionalCursorMargin, -additionalCursorMargin);
    
    // Green LED
    
    BOOL highlightGreenLED = ( deviceState.greenLED == XkeysLEDStateOn );
    
    if ( highlightGreenLED ) {
        [[NSColor colorWithCalibratedRed:0.0 green:0.9 blue:0.0 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedRed:0.75 green:0.9 blue:0.75 alpha:1.0] set];
    }
    
    NSRectFill(greenFrame);
    
    if ( NSPointInRect(cursorLocation, greenCursorFrame) ) {
        [[NSColor colorWithCalibratedRed:0.8 green:1.0 blue:0.8 alpha:1.0] set];
    }
    else if ( highlightGreenLED ) {
        [[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedRed:0.4 green:0.75 blue:0.4 alpha:1.0] set];
    }
    
    NSFrameRect(greenFrame);
    
    // Red LED
    
    BOOL highlightRedLED = ( deviceState.redLED == XkeysLEDStateOn );
    
    if ( highlightRedLED ) {
        [[NSColor colorWithCalibratedRed:0.9 green:0.15 blue:0.15 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedRed:0.9 green:0.75 blue:0.75 alpha:1.0] set];
    }
    
    NSRectFill(redFrame);
    
    if ( NSPointInRect(cursorLocation, redCursorFrame) ) {
        [[NSColor colorWithCalibratedRed:1.0 green:0.9 blue:0.9 alpha:1.0] set];
    }
    else if ( highlightRedLED ) {
        [[NSColor colorWithCalibratedRed:1.0 green:0.4 blue:0.4 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedRed:0.75 green:0.4 blue:0.4 alpha:1.0] set];
    }
    
    NSFrameRect(redFrame);
    
    // Device outline
    
    [[NSColor blackColor] set];
    NSFrameRectWithWidth(deviceFrame, XkeysDeviceViewOutlineThickness);
}

- (void)drawEdgeOverlayInFrame:(NSRect)deviceFrame {
    // Hook for subclasses to draw additional edge items
}

@end
