//
//  Xkeys24Unit.m
//  XkeysFramework
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

#import <XkeysKit/XkeysTypes.h>

#import "XkeysBasicButton.h"
#import "XkeysConnection.h"
#import "XkeysHIDSystem.h"
#import "XkeysIdentifiers.h"
#import "XkeysLEDOutput.h"
#import "XkeysBiColorButton.h"

#import "Xkeys24Unit.h"

void Xkeys24InputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength);

static const uint8_t XK24_REPORT_ID = 0;
static const uint8_t XK24_GREEN_LED_INDEX = 6;
static const uint8_t XK24_RED_LED_INDEX = 7;
static const uint8_t XK24_INPUT_REPORT_LENGTH = 32;
static const uint8_t XK24_OUTPUT_COMMAND_LENGTH = 35;
static const uint8_t XK24_DESCRIPTOR_COMMAND = 214;
static const uint8_t XK24_DESCRIPTOR_REPLY = 214;
static const uint8_t XK24_SET_LED_COMMAND = 179;
static const uint8_t XK24_SET_BACKLIGHT_COMMAND = 181;
static const uint8_t XK24_SET_BACKLIGHT_ROW_COMMAND = 182;
static const uint8_t XK24_SET_BACKLIGHT_INTENSITY_COMMAND = 187;
static const uint8_t XK24_WRITE_BACKLIGHT_STATE = 199;
static const uint8_t XK24_SET_UNITID_COMMAND = 189;
static const uint8_t XK24_SET_PID_COMMAND = 204;

static const uint8_t XK24_MIN_BLUE_BL_INTENSITY = 0x00;
static const uint8_t XK24_MIN_RED_BL_INTENSITY = 0x00;
static const uint8_t XK24_DEFAULT_BL_INTENSITY = 0x80;

static const NSInteger XK24_BUTTON_COUNT = 24;

static const uint8_t XK24_BUFFER_LENGTH = XK24_OUTPUT_COMMAND_LENGTH;

// MARK: - Xkeys24Unit private interface

@interface Xkeys24Unit ()

@property (nonatomic) XkeysUnitID hardwareUnitID;

@property (nonatomic) XkeysLEDOutput *greenLED;
@property (nonatomic) XkeysLEDOutput *redLED;

@property (nonatomic, readwrite) NSArray<XkeysLEDOutput *> *leds;

@property (nonatomic) NSArray<XkeysLEDOutput *> *backlights;
@property (nonatomic) NSArray<XkeysBiColorButton *> *buttons;
@property (nonatomic) XkeysInput *programSwitch;

@property (nonatomic, copy) XkeysBlueRedButtonCallback onButtonChangeCallback;
@property (nonatomic, copy) XkeysControlCallback onProgramSwitchChangeCallback;

@end

// MARK: -

@implementation Xkeys24Unit {
    uint8_t _reportBuffer[XK24_BUFFER_LENGTH];
}

- (instancetype)initWithHIDSystem:(id<XkeysHIDSystem>)hidSystem device:(IOHIDDeviceRef)hidDevice connection:(id<XkeysConnection>)connection {
    
    self = [super initWithHIDSystem:hidSystem device:hidDevice connection:connection];
    if ( ! self ) {
        return nil;
    }
    
    uint32_t targetUsagePage = kHIDPage_Consumer;
    uint32_t targetUsage = kHIDUsage_Csmr_ConsumerControl;
    
    if ( ! connection.receivesData ) {
        // macOS does not create a Consumer Control HID Device for the Hardware Mode XK-24.  Therefore, accept a reference to the Keyboard interface.  (All HID devices have the same underlying USB device.)
        targetUsagePage = kHIDPage_GenericDesktop;
        targetUsage = kHIDUsage_GD_Keyboard;
    }
    
    if ( ! [hidSystem device:hidDevice conformsToUsagePage:targetUsagePage usage:targetUsage] ) {
        return nil;
    }
    
    _greenLED = [[XkeysLEDOutput alloc] initWithDevice:self color:XkeysLEDColorGreen controlIndex:0];
    _redLED = [[XkeysLEDOutput alloc] initWithDevice:self color:XkeysLEDColorRed controlIndex:1];
    
    _backlights = [self buildBacklights];
    _buttons = [self buildButtonInputs];
    _leds = [@[_greenLED, _redLED] arrayByAddingObjectsFromArray:_backlights];
    
    XkeysBasicButton *programSwitch = [[XkeysBasicButton alloc] initWithDevice:self cookie:6 controlIndex:32];
    programSwitch.buttonName = NSLocalizedString(@"Program Switch", @"Name of the XK-24 Program Switch");
    _programSwitch = programSwitch;
    
    return self;
}

- (void)printDebugDescription {
    
    NSLog(@"%@ <%p>: %@ \"%@\"", NSStringFromClass([self class]), self, self.identifier, self.name);
    
    for ( NSObject *led in self.leds ) {
        NSLog(@"\n  %@", [led debugDescription]);
    }
    
    for ( NSObject *button in self.buttons ) {
        NSLog(@"\n  %@", [button debugDescription]);
    }
    
    NSLog(@"\n  %@", [self.programSwitch debugDescription]);
}

// MARK: - XkeysDevice implementation

- (NSString *)name {
    return NSLocalizedString(@"Xkeys XK-24", @"Marketing name of the Xkeys XK-24");
}

- (void)setProductID:(NSInteger)productID {
    
    NSArray *validPIDs = @[ @1027, @1028, @1029, @1249 ];
    NSAssert( [validPIDs containsObject:@(productID)], @"Xkeys XK-24 PIDs must be 1027-1029 or 1249 (not %ld)", productID);
    if ( ! [validPIDs containsObject:@(productID)] ) {
        return;
    }
    
    if ( ! self.isOpen ) {
        return;
    }
    
    [super setProductID:productID];
    
    uint8_t mode = (uint8_t)[validPIDs indexOfObject:@(productID)];
    [self sendReportWithByte0:XK24_SET_PID_COMMAND byte1:mode byte2:0];
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
    [self sendReportWithByte0:XK24_SET_UNITID_COMMAND byte1:unitID byte2:0];
}

- (XkeysDeviceIdentifier)identifier {
    return [XkeysIdentifiers identifierForUnit:self];
}

- (CGFloat)defaultBlueBacklightIntensity {
    return (CGFloat)(XK24_DEFAULT_BL_INTENSITY - XK24_MIN_BLUE_BL_INTENSITY) / (CGFloat)(0xFF - XK24_MIN_BLUE_BL_INTENSITY);
}

- (CGFloat)defaultRedBacklightIntensity {
    return (CGFloat)(XK24_DEFAULT_BL_INTENSITY - XK24_MIN_RED_BL_INTENSITY) / (CGFloat)(0xFF - XK24_MIN_RED_BL_INTENSITY);
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
    [self sendReportWithByte0:XK24_SET_BACKLIGHT_ROW_COMMAND byte1:bankNumber byte2:bankValue];
    
    for ( XkeysLEDOutput *ledOutput in self.backlights ) {
        
        if ( ledOutput.color == color ) {
            ledOutput.ledState = state;
        }
    }
}

- (void)setCalibratedIntensityOfBacklightsToBlue:(CGFloat)blueFraction red:(CGFloat)redFraction {
    
    CGFloat blueComponent = MIN(MAX(blueFraction, 0.0), 1.0);
    CGFloat redComponent = MIN(MAX(redFraction, 0.0), 1.0);
    
    uint8_t blueRange = (0xFF - XK24_MIN_BLUE_BL_INTENSITY);
    uint8_t rawBlueValue = lround((CGFloat)blueRange * blueComponent) + XK24_MIN_BLUE_BL_INTENSITY;
    
    uint8_t redRange = (0xFF - XK24_MIN_RED_BL_INTENSITY);
    uint8_t rawRedValue = lround((CGFloat)redRange * redComponent) + XK24_MIN_RED_BL_INTENSITY;
    
    [self setRawIntensityOfBacklightsToBlue:rawBlueValue red:rawRedValue];
}

- (void)setRawIntensityOfBacklightsToBlue:(uint8_t)blueValue red:(uint8_t)redValue {
    [self sendReportWithByte0:XK24_SET_BACKLIGHT_INTENSITY_COMMAND byte1:blueValue byte2:redValue];
}

- (void)writeBacklightStateToEEPROM {
    [self sendReportWithByte0:XK24_WRITE_BACKLIGHT_STATE byte1:1 byte2:0];
}


// MARK: - Xkeys24 implementation

- (void)onAnyButtonValueChangePerform:(XkeysBlueRedButtonCallback _Nullable)callback {
    self.onButtonChangeCallback = callback;
}

- (void)onProgramSwitchChangePerform:(XkeysControlCallback _Nullable)callback {
    self.onProgramSwitchChangeCallback = callback;
}

// MARK: - XkeysUnit overrides

- (NSArray<XkeysInput *> *)controlInputs {
    return [(NSArray<XkeysInput *> *)self.buttons arrayByAddingObject:self.programSwitch];
}

- (void)initialUnitStateConfigured {
    
    Xkeys24Unit * __weak weakSelf = self;
    
    self.greenLED.onStateChange = ^(XkeysLEDState state){
        Xkeys24Unit *unit = weakSelf;
        [unit sendReportWithByte0:XK24_SET_LED_COMMAND byte1:XK24_GREEN_LED_INDEX byte2:state];
    };
    
    self.redLED.onStateChange = ^(XkeysLEDState state){
        Xkeys24Unit *unit = weakSelf;
        [unit sendReportWithByte0:XK24_SET_LED_COMMAND byte1:XK24_RED_LED_INDEX byte2:state];
    };
    
    [super initialUnitStateConfigured];
}

- (void)open {
    
    [super open];
    
    if ( self.connection.receivesData ) {
        
        [self startListeningForInputReports];
        [self sendDescriptorRequest];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initialUnitStateConfigured];
        });
    }
}

- (NSArray<XkeysLEDOutput *> *)buildBacklights {
    
    NSMutableArray *backlightOutputs = [NSMutableArray array];
    
    __weak Xkeys24Unit *weakSelf = self;
    
    const NSInteger numberOfBacklightBanks = 2;
    const NSInteger numberOfButtonRows = 6;
    const NSInteger numberOfButtonColumns = 4;
    
    // The XK-24 buttons are numbered as though there were 8 buttons per column
    const NSInteger buttonNumbersPerColumn = 8;
    
    // Index of the Red backlight is offset by 32 from the Blue backlight on a given button
    const NSInteger backlightBankOffset = 32;
    
    for ( NSInteger bankIndex = 0 ; bankIndex < numberOfBacklightBanks ; bankIndex++ ) {
        
        XkeysLEDColor color = ( bankIndex == 0 ? XkeysLEDColorBlue : XkeysLEDColorRed );
        
        for ( NSInteger columnIndex = 0 ; columnIndex < numberOfButtonColumns ; columnIndex++ ) {
            
            for ( NSInteger rowIndex = 0 ; rowIndex < numberOfButtonRows ; rowIndex++ ) {
                
                // Indexes 0 and 1 are the device's green and red LEDs respectively
                NSInteger controlIndex = (NSInteger)backlightOutputs.count + 2;
                
                XkeysLEDOutput *ledOutput = [[XkeysLEDOutput alloc] initWithDevice:self color:color controlIndex:controlIndex];
                
                NSInteger buttonNumber = ( columnIndex * buttonNumbersPerColumn ) + rowIndex;
                NSInteger backlightIndex = ( bankIndex * backlightBankOffset ) + buttonNumber;
                
                ledOutput.onStateChange = ^(XkeysLEDState state){
                    Xkeys24Unit *unit = weakSelf;
                    [unit sendReportWithByte0:XK24_SET_BACKLIGHT_COMMAND byte1:backlightIndex byte2:state];
                };
                
                [backlightOutputs addObject:ledOutput];
            }
        }
    }
    
    return backlightOutputs;
}

- (NSArray<XkeysBiColorButton *> *)buildButtonInputs {
    
    NSAssert(self.backlights.count == (XK24_BUTTON_COUNT * 2), @"Backlights are expected to be created before the buttons");
    if ( self.backlights.count != (XK24_BUTTON_COUNT * 2) ) {
        return @[];
    }

    NSMutableArray *controlInputs = [NSMutableArray array];
    
    NSString *backlightNameFormat = NSLocalizedString(@"%@ %@ Backlight", @"Format of the name of a colored LED that illuminates a button from beneath in the form 'Button #3 Red Backlight'");
    NSString *blueColorName = [XkeysLEDOutput nameForColor:XkeysLEDColorBlue];
    NSString *redColorName = [XkeysLEDOutput nameForColor:XkeysLEDColorRed];

    NSInteger backlightIndex = 0;
    
    const NSInteger numberOfButtonRows = 6;
    const NSInteger numberOfButtonColumns = 4;
    
    // The XK-24 buttons are numbered as though there were 8 buttons per column
    const NSInteger buttonNumbersPerColumn = 8;
    
    // The state of the buttons are reported in a series of HID elements, each element containing the state one column of buttons.
    const IOHIDElementCookie elementCookieOfFirstColumn = 7;
    
    for ( NSInteger columnIndex = 0 ; columnIndex < numberOfButtonColumns ; columnIndex++ ) {
        
        for ( NSInteger rowIndex = 0 ; rowIndex < numberOfButtonRows ; rowIndex++ ) {
            
            NSInteger buttonNumber = ( columnIndex * buttonNumbersPerColumn ) + rowIndex;
            
            IOHIDElementCookie cookie = (IOHIDElementCookie)columnIndex + elementCookieOfFirstColumn;
            
            XkeysBiColorButton *button = [[XkeysBiColorButton alloc] initWithDevice:self cookie:cookie bitIndex:rowIndex controlIndex:buttonNumber];
            
            NSInteger blueBacklightIndex = backlightIndex;
            NSInteger redBacklightIndex = blueBacklightIndex + XK24_BUTTON_COUNT;
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
    
    if ( self.programSwitch.cookie == cookie ) {
        
        [self.programSwitch handleInputValue:value];
        [self invokeOnProgramSwitchCallback];
        [self invokeControlValueChangeCallbacksWithControl:self.programSwitch];

        return;
    }
    
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
}

// MARK: - Xkeys24Unit internal

- (void)startListeningForInputReports {
    
    void *context = (__bridge void *)self;
    [self.hidSystem device:self.hidDevice registerInputReport:_reportBuffer length:sizeof(_reportBuffer) callback:Xkeys24InputReportCallback context:context];
}

- (void)stopListeningForInputReports {
    [self.hidSystem device:self.hidDevice registerInputReport:_reportBuffer length:sizeof(_reportBuffer) callback:NULL context:NULL];
}

- (void)sendDescriptorRequest {
    [self sendReportWithByte0:XK24_DESCRIPTOR_COMMAND byte1:0 byte2:0];
}

- (void)sendReportWithByte0:(uint8_t)byte0 byte1:(uint8_t)byte1 byte2:(uint8_t)byte2 {
    
    if ( ! self.isOpen ) {
        return;
    }
    
    bzero(_reportBuffer, sizeof(_reportBuffer));
    
    _reportBuffer[0] = byte0;
    _reportBuffer[1] = byte1;
    _reportBuffer[2] = byte2;
    
    [self.connection sendReportBytes:_reportBuffer ofLength:XK24_OUTPUT_COMMAND_LENGTH];
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

- (void)invokeOnProgramSwitchCallback {
    
    XkeysControlCallback callback = self.onProgramSwitchChangeCallback;
    if ( callback == NULL ) {
        return;
    }
    
    if ( ! callback(self.programSwitch) ) {
        self.onProgramSwitchChangeCallback = NULL;
    }
}

@end

// MARK: - Private functions

void Xkeys24InputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength) {
    
    Xkeys24Unit *unit = (__bridge Xkeys24Unit *)context;
    NSCAssert([unit isKindOfClass:[Xkeys24Unit class]], @"");
    if ( ! [unit isKindOfClass:[Xkeys24Unit class]] ) {
        return;
    }
    
    NSCAssert(report != NULL, @"");
    if ( report == NULL ) {
        return;
    }
    
    NSCAssert(reportID == XK24_REPORT_ID, @"%u", reportID);
    if ( reportID != XK24_REPORT_ID ) {
        return;
    }
    
    NSCAssert(reportLength == XK24_INPUT_REPORT_LENGTH, @"%ld", reportLength);
    if ( reportLength != XK24_INPUT_REPORT_LENGTH ) {
        return;
    }
    
    uint8_t replyDataType = report[1];
    
    if ( replyDataType == XK24_DESCRIPTOR_REPLY ) {
        
        uint8_t ledStatus = report[9];
        
        unit.greenLED.state = ( (ledStatus & (1 << XK24_GREEN_LED_INDEX)) == 0 ? XkeysLEDStateOff : XkeysLEDStateOn );
        unit.redLED.state = ( (ledStatus & (1 << XK24_RED_LED_INDEX)) == 0 ? XkeysLEDStateOff : XkeysLEDStateOn );
        
        unit.hardwareUnitID = (NSInteger)report[0];
        
        [unit stopListeningForInputReports];
        [unit initialUnitStateConfigured];
    }
}
