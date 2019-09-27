//
//  Xkeys124TbarUnit.m
//  XkeysFramework
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

#import <XkeysKit/XkeysTypes.h>

#import "XkeysConnection.h"
#import "XkeysHIDSystem.h"
#import "XkeysIdentifiers.h"
#import "XkeysLEDOutput.h"
#import "XkeysBiColorButton.h"
#import "XkeysSliderInput.h"

#import "Xkeys124TbarUnit.h"

void Xkeys124TbarInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength);

static const uint8_t XKE124_REPORT_ID = 0;
static const uint8_t XKE124_GREEN_LED_INDEX = 6;
static const uint8_t XKE124_RED_LED_INDEX = 7;
static const uint8_t XKE124_INPUT_REPORT_LENGTH = 36;
static const uint8_t XKE124_OUTPUT_COMMAND_LENGTH = 35;
static const uint8_t XKE124_GENERATE_DATA_COMMAND = 177;
static const uint8_t XKE124_GENERATE_DATA_REPLY = 2;
static const uint8_t XKE124_DESCRIPTOR_COMMAND = 214;
static const uint8_t XKE124_DESCRIPTOR_REPLY = 214;
static const uint8_t XKE124_SET_LED_COMMAND = 179;
static const uint8_t XKE124_SET_BACKLIGHT_COMMAND = 181;
static const uint8_t XKE124_SET_BACKLIGHT_ROW_COMMAND = 182;
static const uint8_t XKE124_SET_BACKLIGHT_INTENSITY_COMMAND = 187;
static const uint8_t XKE124_WRITE_BACKLIGHT_STATE = 199;
static const uint8_t XKE124_SET_UNITID_COMMAND = 189;
static const uint8_t XKE124_SET_PID_COMMAND = 204;

static const uint8_t XKE124_MIN_BLUE_BL_INTENSITY = 0x6B;
static const uint8_t XKE124_MIN_RED_BL_INTENSITY = 0x4A;
static const uint8_t XKE124_DEFAULT_BL_INTENSITY = 0x80;

static const uint8_t XKE124_BUTTON_COUNT = 124;

static const uint8_t XKE124_BUFFER_LENGTH = XKE124_INPUT_REPORT_LENGTH;

// MARK: - Xkeys124TbarUnit private interface

@interface Xkeys124TbarUnit ()

@property (nonatomic) XkeysUnitID hardwareUnitID;

@property (nonatomic) XkeysLEDOutput *greenLED;
@property (nonatomic) XkeysLEDOutput *redLED;

@property (nonatomic, readwrite) NSArray<XkeysLEDOutput *> *leds;

@property (nonatomic) NSArray<XkeysLEDOutput *> *backlights;
@property (nonatomic) NSArray<XkeysBiColorButton *> *buttons;
@property (nonatomic) XkeysInput *tbar;
@property (nonatomic) NSArray<XkeysInput *> *allControls;

@property (nonatomic, copy) XkeysBlueRedButtonCallback onButtonChangeCallback;
@property (nonatomic, copy) XkeysControlCallback onTbarChangeCallback;

@end

// MARK: -

@implementation Xkeys124TbarUnit {
    uint8_t _reportBuffer[XKE124_BUFFER_LENGTH];
}

- (instancetype)initWithHIDSystem:(id<XkeysHIDSystem>)hidSystem device:(IOHIDDeviceRef)hidDevice connection:(id<XkeysConnection>)connection {
    
    self = [super initWithHIDSystem:hidSystem device:hidDevice connection:connection];
    if ( ! self ) {
        return nil;
    }
    
    if ( ! [hidSystem device:hidDevice conformsToUsagePage:kHIDPage_Consumer usage:kHIDUsage_Csmr_ConsumerControl] ) {
        return nil;
    }
    
    _greenLED = [[XkeysLEDOutput alloc] initWithDevice:self color:XkeysLEDColorGreen controlIndex:0];
    _redLED = [[XkeysLEDOutput alloc] initWithDevice:self color:XkeysLEDColorRed controlIndex:1];
    
    _backlights = [self buildBacklights];
    _buttons = [self buildButtonInputs];
    
    IOHIDElementCookie tbarCookie = 33;
    if ( [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 15 ) {
        tbarCookie += 2;
    }
    
    NSString *tbarName = NSLocalizedString(@"T-bar", @"User-visible name of the t-bar control on the XKE-124");
    _tbar = [[XkeysSliderInput alloc] initWithDevice:self cookie:tbarCookie name:tbarName controlIndex:0];
    _allControls = [(NSArray<XkeysInput *> *)_buttons arrayByAddingObject:_tbar];
    
    _leds = [@[_greenLED, _redLED] arrayByAddingObjectsFromArray:_backlights];
    
    return self;
}

- (void)printDebugDescription {
    
    NSLog(@"%@ <%p>: %@ \"%@\"", NSStringFromClass([self class]), self, self.identifier, self.name);
    
    for ( NSObject *led in self.leds ) {
        NSLog(@"\n  %@", [led debugDescription]);
    }
    
    for ( NSObject *control in self.allControls ) {
        NSLog(@"\n  %@", [control debugDescription]);
    }
}

// MARK: - XkeysDevice implementation

- (NSString *)name {
    return NSLocalizedString(@"Xkeys XKE-124 T-bar", @"Marketing name of the Xkeys XKE-124 T-bar");
}

- (void)setProductID:(NSInteger)productID {
    
    NSArray *validPIDs = @[ @1275, @1276, @1277, @1278 ];
    NSAssert( [validPIDs containsObject:@(productID)], @"Xkeys XKE-124 Tbar PIDs must be 1275-1278 (not %ld)", productID);
    if ( ! [validPIDs containsObject:@(productID)] ) {
        return;
    }
    
    if ( ! self.isOpen ) {
        return;
    }
    
    [super setProductID:productID];
    
    uint8_t mode = (uint8_t)[validPIDs indexOfObject:@(productID)];
    [self sendReportWithByte0:XKE124_SET_PID_COMMAND byte1:mode byte2:0];
}

- (XkeysUnitID)unitID {
    return self.hardwareUnitID;
}

- (void)setUnitID:(XkeysUnitID)unitID {
    
    if ( ! self.isOpen ) {
        return;
    }
    
    if ( unitID == self.hardwareUnitID ) {
        return;
    }
    
    self.hardwareUnitID = unitID;
    [self sendReportWithByte0:XKE124_SET_UNITID_COMMAND byte1:unitID byte2:0];
}

- (XkeysDeviceIdentifier)identifier {
    return [XkeysIdentifiers identifierForUnit:self];
}

- (CGFloat)defaultBlueBacklightIntensity {
    return (CGFloat)(XKE124_DEFAULT_BL_INTENSITY - XKE124_MIN_BLUE_BL_INTENSITY) / (CGFloat)(0xFF - XKE124_MIN_BLUE_BL_INTENSITY);
}

- (CGFloat)defaultRedBacklightIntensity {
    return (CGFloat)(XKE124_DEFAULT_BL_INTENSITY - XKE124_MIN_RED_BL_INTENSITY) / (CGFloat)(0xFF - XKE124_MIN_RED_BL_INTENSITY);
}

- (id<XkeysBlueRedButton> _Nullable)buttonWithButtonNumber:(NSInteger)buttonNumber {
    
    for ( XkeysBiColorButton *button in self.buttons ) {
        
        if ( button.buttonNumber == buttonNumber ) {
            return button;
        }
    }
    
    return nil;
}

- (id<XkeysControl> _Nullable)controlWithIdentifier:(XkeysControlIdentifier)identifier {
    
    for ( XkeysBiColorButton *button in self.buttons ) {
        
        if ( [XkeysIdentifiers identifier:identifier matchesInput:button] ) {
            return button;
        }
    }
    
    if ( [XkeysIdentifiers identifier:identifier matchesInput:self.tbar] ) {
        return self.tbar;
    }
    
    return nil;
}

- (id<XkeysLED> _Nullable)ledWithIdentifier:(XkeysControlIdentifier)identifier {
    
    for ( XkeysLEDOutput *led in self.leds ) {
        
        if ( [XkeysIdentifiers identifier:identifier matchesLED:led] ) {
            return led;
        }
    }
    
    return nil;
}

- (BOOL)matchesIdentifier:(XkeysIdentifier)identifier {
    return [XkeysIdentifiers identifier:identifier matchesUnit:self];
}

- (void)setAllBacklightsWithColor:(XkeysLEDColor)color toState:(XkeysLEDState)state {
    
    NSArray *validColors = @[ @(XkeysLEDColorBlue), @(XkeysLEDColorRed) ];
    NSAssert( [validColors containsObject:@(color)], @"Backlight color must be XkeysLEDColorBlue or XkeysLEDColorRed (not %ld)", color );
    if ( ! [validColors containsObject:@(color)] ) {
        return;
    }
    
    if ( ! self.isOpen ) {
        return;
    }
    
    uint8_t bankNumber = (uint8_t)[validColors indexOfObject:@(color)];
    uint8_t bankValue = ( state == XkeysLEDStateOn ? 0xFF : 0x00 );
    [self sendReportWithByte0:XKE124_SET_BACKLIGHT_ROW_COMMAND byte1:bankNumber byte2:bankValue];
    
    for ( XkeysLEDOutput *ledOutput in self.backlights ) {
        
        if ( ledOutput.color == color ) {
            ledOutput.ledState = state;
        }
    }
}

- (void)setCalibratedIntensityOfBacklightsToBlue:(CGFloat)blueFraction red:(CGFloat)redFraction {
    
    CGFloat blueComponent = MIN(MAX(blueFraction, 0.0), 1.0);
    CGFloat redComponent = MIN(MAX(redFraction, 0.0), 1.0);
    
    uint8_t blueRange = (0xFF - XKE124_MIN_BLUE_BL_INTENSITY);
    uint8_t rawBlueValue = lround((CGFloat)blueRange * blueComponent) + XKE124_MIN_BLUE_BL_INTENSITY;
    
    uint8_t redRange = (0xFF - XKE124_MIN_RED_BL_INTENSITY);
    uint8_t rawRedValue = lround((CGFloat)redRange * redComponent) + XKE124_MIN_RED_BL_INTENSITY;
    
    [self setRawIntensityOfBacklightsToBlue:rawBlueValue red:rawRedValue];
}

- (void)setRawIntensityOfBacklightsToBlue:(uint8_t)blueValue red:(uint8_t)redValue {
    [self sendReportWithByte0:XKE124_SET_BACKLIGHT_INTENSITY_COMMAND byte1:blueValue byte2:redValue];
}

- (void)writeBacklightStateToEEPROM {
    [self sendReportWithByte0:XKE124_WRITE_BACKLIGHT_STATE byte1:1 byte2:0];
}


// MARK: - Xkeys124Tbar implementation

- (void)onAnyButtonValueChangePerform:(XkeysBlueRedButtonCallback _Nullable)callback {
    self.onButtonChangeCallback = callback;
}

- (void)onTbarValueChangePerform:(XkeysControlCallback _Nullable)callback {
    self.onTbarChangeCallback = callback;
}

// MARK: - XkeysUnit overrides

- (NSArray<XkeysInput *> *)controlInputs {
    return self.allControls;
}

- (void)initialUnitStateConfigured {
    
    Xkeys124TbarUnit * __weak weakSelf = self;
    
    self.greenLED.onStateChange = ^(XkeysLEDState state){
        Xkeys124TbarUnit *unit = weakSelf;
        [unit sendReportWithByte0:XKE124_SET_LED_COMMAND byte1:XKE124_GREEN_LED_INDEX byte2:state];
    };
    
    self.redLED.onStateChange = ^(XkeysLEDState state){
        Xkeys124TbarUnit *unit = weakSelf;
        [unit sendReportWithByte0:XKE124_SET_LED_COMMAND byte1:XKE124_RED_LED_INDEX byte2:state];
    };
    
    [super initialUnitStateConfigured];
}

- (void)open {
    
    [super open];
    
    if ( self.connection.receivesData ) {
        
        [self startListeningForInputReports];
        [self sendGeneralDataReportRequest];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initialUnitStateConfigured];
        });
    }
}

- (NSArray<XkeysLEDOutput *> *)buildBacklights {
    
    NSMutableArray *backlightOutputs = [NSMutableArray array];
    
    __weak Xkeys124TbarUnit *weakSelf = self;
    
    const NSInteger numberOfBacklightBanks = 2;
    const NSInteger numberOfButtonRows = 8;
    const NSInteger numberOfButtonColumns = 16;
    
    // Index of the Red backlight is offset by 128 from the Blue backlight on a given button
    const NSInteger backlightBankOffset = 128;
    
    for ( NSInteger bankIndex = 0 ; bankIndex < numberOfBacklightBanks ; bankIndex++ ) {
        
        XkeysLEDColor color = ( bankIndex == 0 ? XkeysLEDColorBlue : XkeysLEDColorRed );
        
        for ( NSInteger columnIndex = 0 ; columnIndex < numberOfButtonColumns ; columnIndex++ ) {
            
            for ( NSInteger rowIndex = 0 ; rowIndex < numberOfButtonRows ; rowIndex++ ) {
                
                if ( columnIndex == 13 && rowIndex >= 4 ) {
                    // On the XKE124Tbar, the T-bar occupies the 14th column of buttons in the last four rows.
                    continue;
                }
                
                NSInteger buttonNumber = ( columnIndex * numberOfButtonRows ) + rowIndex;
                NSInteger backlightIndex = ( bankIndex * backlightBankOffset ) + buttonNumber;

                // Indexes 0 and 1 are the device's green and red LEDs respectively
                NSInteger controlIndex = backlightIndex + 2;
                
                XkeysLEDOutput *ledOutput = [[XkeysLEDOutput alloc] initWithDevice:self color:color controlIndex:controlIndex];
                
                ledOutput.onStateChange = ^(XkeysLEDState state){
                    Xkeys124TbarUnit *unit = weakSelf;
                    [unit sendReportWithByte0:XKE124_SET_BACKLIGHT_COMMAND byte1:backlightIndex byte2:state];
                };
                
                [backlightOutputs addObject:ledOutput];
            }
        }
    }
    
    return backlightOutputs;
}

- (NSArray<XkeysBiColorButton *> *)buildButtonInputs {
    
    NSAssert(self.backlights.count == (XKE124_BUTTON_COUNT * 2), @"Backlights are expected to be created before the buttons");
    if ( self.backlights.count != (XKE124_BUTTON_COUNT * 2) ) {
        return @[];
    }
    
    NSMutableArray *controlInputs = [NSMutableArray array];
    
    NSString *backlightNameFormat = NSLocalizedString(@"%@ %@ Backlight", @"Format of the name of a colored LED that illuminates a button from beneath in the form 'Button #3 Red Backlight'");
    NSString *blueColorName = [XkeysLEDOutput nameForColor:XkeysLEDColorBlue];
    NSString *redColorName = [XkeysLEDOutput nameForColor:XkeysLEDColorRed];

    NSInteger backlightIndex = 0;
    
    const NSInteger numberOfButtonRows = 8;
    const NSInteger numberOfButtonColumns = 16;
    
    // The state of the buttons are reported in a series of HID elements, each element containing the state one column of buttons.
    IOHIDElementCookie elementCookieOfFirstColumn = 7;
    if ( [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 15 ) {
        elementCookieOfFirstColumn += 2;
    }
    
    for ( NSInteger columnIndex = 0 ; columnIndex < numberOfButtonColumns ; columnIndex++ ) {
        
        for ( NSInteger rowIndex = 0 ; rowIndex < numberOfButtonRows ; rowIndex++ ) {
            
            if ( columnIndex == 13 && rowIndex >= 4 ) {
                // On the XKE124Tbar, the T-bar occupies the 14th column of buttons in the last four rows.
                continue;
            }
            
            NSInteger buttonNumber = ( columnIndex * numberOfButtonRows ) + rowIndex;
            
            IOHIDElementCookie cookie = (IOHIDElementCookie)columnIndex + elementCookieOfFirstColumn;
            
            XkeysBiColorButton *button = [[XkeysBiColorButton alloc] initWithDevice:self cookie:cookie bitIndex:rowIndex controlIndex:buttonNumber];
            
            NSInteger blueBacklightIndex = backlightIndex;
            NSInteger redBacklightIndex = blueBacklightIndex + XKE124_BUTTON_COUNT;
            backlightIndex += 1;
            
            XkeysLEDOutput *blueBacklight = self.backlights[blueBacklightIndex];
            blueBacklight.name = [NSString stringWithFormat:backlightNameFormat, button.name, blueColorName];
            button.blueLED = blueBacklight;
            
            XkeysLEDOutput *redBacklight = self.backlights[redBacklightIndex];
            redBacklight.name = [NSString stringWithFormat:backlightNameFormat, button.name, redColorName];
            button.redLED = redBacklight;
            
            [controlInputs addObject:button];
        }
    }
    
    return controlInputs;
}

- (void)handleInputValue:(CFIndex)value fromCookie:(IOHIDElementCookie)cookie {
    
    for ( XkeysBiColorButton *button in self.buttons ) {
        
        if ( button.cookie != cookie ) {
            continue;
        }
        
        if ( ! [button handleInputValue:value] ) {
            continue;
        }
        
        [self invokeOnAnyButtonCallbackWithButton:button];
        [self invokeControlValueChangeCallbacksWithControl:button];
    }
    
    if ( self.tbar.cookie != cookie ) {
        return;
    }
    
    if ( ! [self.tbar handleInputValue:value] ) {
        return;
    }
    
    [self invokeOnTbarChangeWithTbar:self.tbar];
    [self invokeControlValueChangeCallbacksWithControl:self.tbar];
}

// MARK: - Xkeys124TbarUnit internal

- (void)startListeningForInputReports {
    
    void *context = (__bridge void *)self;
    [self.hidSystem device:self.hidDevice registerInputReport:_reportBuffer length:sizeof(_reportBuffer) callback:Xkeys124TbarInputReportCallback context:context];
}

- (void)stopListeningForInputReports {
    [self.hidSystem device:self.hidDevice registerInputReport:_reportBuffer length:sizeof(_reportBuffer) callback:NULL context:NULL];
}

- (void)sendGeneralDataReportRequest {
    [self sendReportWithByte0:XKE124_GENERATE_DATA_COMMAND byte1:0 byte2:0];
}

- (void)sendDescriptorRequest {
    [self sendReportWithByte0:XKE124_DESCRIPTOR_COMMAND byte1:0 byte2:0];
}

- (void)sendReportWithByte0:(uint8_t)byte0 byte1:(uint8_t)byte1 byte2:(uint8_t)byte2 {
    
    if ( ! self.isOpen ) {
        return;
    }
    
    bzero(_reportBuffer, sizeof(_reportBuffer));
    
    _reportBuffer[0] = byte0;
    _reportBuffer[1] = byte1;
    _reportBuffer[2] = byte2;
    
    [self.connection sendReportBytes:_reportBuffer ofLength:XKE124_OUTPUT_COMMAND_LENGTH];
}

- (void)invokeOnAnyButtonCallbackWithButton:(XkeysBiColorButton *)button {
    
    XkeysControlCallback callback = self.onButtonChangeCallback;
    if ( callback == NULL ) {
        return;
    }
    
    if ( ! callback(button) ) {
        self.onButtonChangeCallback = NULL;
    }
}

- (void)invokeOnTbarChangeWithTbar:(XkeysInput *)tbar {
    
    XkeysControlCallback callback = self.onTbarChangeCallback;
    if ( callback == NULL ) {
        return;
    }
    
    if ( ! callback(tbar) ) {
        self.onTbarChangeCallback = NULL;
    }
}

@end

// MARK: - Private functions

void Xkeys124TbarInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength) {
    
    Xkeys124TbarUnit *unit = (__bridge Xkeys124TbarUnit *)context;
    NSCAssert([unit isKindOfClass:[Xkeys124TbarUnit class]], @"");
    if ( ! [unit isKindOfClass:[Xkeys124TbarUnit class]] ) {
        return;
    }
    
    NSCAssert(report != NULL, @"");
    if ( report == NULL ) {
        return;
    }
    
    NSCAssert(reportID == XKE124_REPORT_ID, @"%u", reportID);
    if ( reportID != XKE124_REPORT_ID ) {
        return;
    }
    
    NSCAssert(reportLength == 36, @"%ld", reportLength);
    if ( reportLength != 36 ) {
        return;
    }
    
    uint8_t replyDataType = report[1];
    
    if ( replyDataType == XKE124_GENERATE_DATA_REPLY ) {
        
        unit.hardwareUnitID = (NSInteger)report[0];
        [unit.tbar handleInputValue:(CFIndex)report[28]];
        [unit sendDescriptorRequest];
    }
    else if ( replyDataType == XKE124_DESCRIPTOR_REPLY ) {
        
        uint8_t ledStatus = report[9];
        
        unit.greenLED.state = ( (ledStatus & (1 << XKE124_GREEN_LED_INDEX)) == 0 ? XkeysLEDStateOff : XkeysLEDStateOn );
        unit.redLED.state = ( (ledStatus & (1 << XKE124_RED_LED_INDEX)) == 0 ? XkeysLEDStateOff : XkeysLEDStateOn );
        
        [unit stopListeningForInputReports];
        [unit initialUnitStateConfigured];
    }
}
