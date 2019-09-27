//
//  Xkeys24Tests.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 3/2/18.
//  Copyright © 2018 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import <XCTest/XCTest.h>

#import "MockHIDElement.h"
#import "MockHIDManager.h"
#import "MockHIDOutputReport.h"
#import "MockHIDValue.h"
#import "MockXK24.h"
#import "XkeysTestHIDSystem.h"
#import "XkeysServer+Private.h"

@interface Xkeys24Tests : XCTestCase

@end

@implementation Xkeys24Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIdentifierMatching {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    // Test
    
    XCTAssertTrue([attachedDevice matchesIdentifier:@"xkeys://1/1523/1027/0"]);
    XCTAssertFalse([attachedDevice matchesIdentifier:@"xkeys://1/1523/1028/0"]);
    XCTAssertTrue([attachedDevice matchesIdentifier:@"xkeys://1/1523/1029/0"]);
    XCTAssertFalse([attachedDevice matchesIdentifier:@"xkeys://1/1523/1249/0"]);
    XCTAssertTrue([attachedDevice matchesIdentifier:@"xkeys://1/1523/1029/100"]);
    XCTAssertTrue([attachedDevice matchesIdentifier:@"xkeys://1/1523/1029/*"]);
}

- (void)testThatButtonsAreCreatedCorrectly {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    // Test
    
    XCTAssertEqual(attachedDevice.buttons.count, 24);
    
    for ( NSInteger columnIndex = 0 ; columnIndex < 4 ; columnIndex++ ) {
        
        for ( NSInteger rowIndex = 0 ; rowIndex < 8 ; rowIndex++ ) {
            
            NSInteger buttonNumber = (columnIndex * 8) + rowIndex;
            
            id<XkeysBlueRedButton> buttonByNumber = [attachedDevice buttonWithButtonNumber:buttonNumber];
            
            NSString *identifier = [NSString stringWithFormat:@"xkeys://1/1523/1029/0/button:%ld", buttonNumber];
            id<XkeysBlueRedButton> buttonByIdentifier = (id<XkeysBlueRedButton>)[attachedDevice controlWithIdentifier:identifier];
            
            if ( rowIndex >= 6 ) {
                XCTAssertNil(buttonByNumber, @"%ld", buttonNumber);
                XCTAssertNil(buttonByIdentifier, @"%ld", buttonNumber);
                continue;
            }
            
            XCTAssertNotNil(buttonByNumber, @"%ld", buttonNumber);
            XCTAssertNotNil(buttonByIdentifier, @"%ld", buttonNumber);
            XCTAssertTrue(buttonByNumber == buttonByIdentifier);
            
            XCTAssertEqual(buttonByNumber.minimumValue, 0);
            XCTAssertEqual(buttonByNumber.maximumValue, 1);
            
            NSString *expectedName = [NSString stringWithFormat:@"Button #%ld", buttonNumber];
            XCTAssertEqualObjects(buttonByNumber.name, expectedName);
        }
    }
    
    XCTAssertNotNil(attachedDevice.programSwitch);
    XCTAssertEqual(attachedDevice.programSwitch.minimumValue, 0);
    XCTAssertEqual(attachedDevice.programSwitch.maximumValue, 1);
    XCTAssertEqualObjects(attachedDevice.programSwitch.name, @"Program Switch");
}

- (void)testThatLEDOutputsAreCreatedCorrectly {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    // Test
    
    NSArray<id<XkeysLED>> *leds = attachedDevice.leds;
    XCTAssertNotNil(leds);
    XCTAssertEqual(leds.count, 50);
    
    id<XkeysLED> greenLED = attachedDevice.greenLED;
    XCTAssertTrue(leds[0] == greenLED);
    XCTAssertEqualObjects(greenLED.name, @"Green LED");
    XCTAssertEqualObjects(greenLED.identifier, @"xkeys://1/1523/1029/0/led:0");
    XCTAssertEqual(greenLED.color, XkeysLEDColorGreen);
    XCTAssertTrue(greenLED.device == attachedDevice);
    
    id<XkeysLED> redLED = attachedDevice.redLED;
    XCTAssertTrue(leds[1] == redLED);
    XCTAssertEqualObjects(redLED.name, @"Red LED");
    XCTAssertEqualObjects(redLED.identifier, @"xkeys://1/1523/1029/0/led:1");
    XCTAssertEqual(redLED.color, XkeysLEDColorRed);
    XCTAssertTrue(redLED.device == attachedDevice);
    
    XCTAssertTrue([attachedDevice ledWithIdentifier:@"xkeys://1/1523/1029/0/led:0"] == greenLED);
    XCTAssertTrue([attachedDevice ledWithIdentifier:@"xkeys://1/1523/1029/*/led:1"] == redLED);
    
    for ( NSInteger columnIndex = 0 ; columnIndex <= 3 ; columnIndex++ ) {
        
        for ( NSInteger rowIndex = 0 ; rowIndex <= 7 ; rowIndex++ ) {
            
            if ( rowIndex >= 6 ) {
                continue;
            }
            
            NSInteger buttonNumber = (columnIndex * 8) + rowIndex;
            NSInteger blueLEDIndex = (columnIndex * 6) + rowIndex + 2;
            NSInteger redLEDIndex = blueLEDIndex + 24;
            
            NSString *expectedBlueIdentifier = [NSString stringWithFormat:@"xkeys://1/1523/1029/0/led:%ld", blueLEDIndex];
            NSString *expectedRedIdentifier = [NSString stringWithFormat:@"xkeys://1/1523/1029/0/led:%ld", redLEDIndex];
            
            NSString *expectedBlueName = [NSString stringWithFormat:@"Button #%ld Blue Backlight", buttonNumber];
            NSString *expectedRedName = [NSString stringWithFormat:@"Button #%ld Red Backlight", buttonNumber];
            
            id<XkeysBlueRedButton> button = [attachedDevice buttonWithButtonNumber:buttonNumber];
            
            id<XkeysLED> blueBacklight = [attachedDevice ledWithIdentifier:expectedBlueIdentifier];
            XCTAssertNotNil(blueBacklight, @"%ld", buttonNumber);
            
            id<XkeysLED> redBacklight = [attachedDevice ledWithIdentifier:expectedRedIdentifier];
            XCTAssertNotNil(redBacklight, @"%ld", buttonNumber);
            
            XCTAssertTrue(button.blueLED == blueBacklight, @"%ld", buttonNumber);
            XCTAssertTrue(button.redLED == redBacklight, @"%ld", buttonNumber);
            
            XCTAssertEqual(blueBacklight.color, XkeysLEDColorBlue, @"%ld", buttonNumber);
            XCTAssertEqual(redBacklight.color, XkeysLEDColorRed, @"%ld", buttonNumber);
            
            XCTAssertTrue(blueBacklight.device == attachedDevice, @"%ld", buttonNumber);
            XCTAssertTrue(redBacklight.device == attachedDevice, @"%ld", buttonNumber);
            
            XCTAssertEqualObjects(blueBacklight.name, expectedBlueName, @"%ld", buttonNumber);
            XCTAssertEqualObjects(redBacklight.name, expectedRedName, @"%ld", buttonNumber);
        }
    }
}

- (void)testButtonHandlers {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    // Setup device callback blocks
    
    __block NSString *buttonIdentifier = nil;
    __block NSInteger buttonNumber = -1;
    __block NSInteger buttonValue = -1;
    
    [attachedDevice onAnyButtonValueChangePerform:^BOOL(id<XkeysBlueRedButton> button) {
        buttonIdentifier = button.identifier;
        buttonNumber = button.buttonNumber;
        buttonValue = button.currentValue;
        return YES;
    }];
    
    __block NSString *controlIdentifier = nil;
    __block NSInteger controlValue = -1;
    
    [attachedDevice onAnyControlValueChangePerform:^BOOL(id<XkeysControl> control) {
        controlIdentifier = control.identifier;
        controlValue = control.currentValue;
        return YES;
    }];
    
    __block NSInteger programSwitchValue = -1;
    
    [attachedDevice onProgramSwitchChangePerform:^BOOL(id<XkeysControl> control) {
        programSwitchValue = control.currentValue;
        return YES;
    }];
    
    // Test individual buttons
    
    IOHIDElementCookie firstCookie = 7;
    IOHIDElementCookie lastCookie = 10;
    
    if ( [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 15 ) {
        firstCookie += 2;
        lastCookie += 2;
    }
    
    for ( IOHIDElementCookie cookie = firstCookie ; cookie <= lastCookie ; cookie++ ) {
        
        MockHIDElement *element = [[MockHIDElement alloc] initWithCookie:cookie];
        
        for ( NSInteger index = 0 ; index <= 5 ; index++ ) {
            
            uint32_t mask = (1 << index);
            
            NSInteger expectedButtonNumber = (cookie - firstCookie) * 8 + index ;
            NSString *expectedIdentifier = [NSString stringWithFormat:@"xkeys://1/1523/1029/0/button:%ld", expectedButtonNumber];
            NSString *message = [NSString stringWithFormat:@"cookie: %ld index: %ld", (NSInteger)cookie, index];
            
            [mockDevice postInputValue:[[MockHIDValue alloc] initWithElement:element value:mask]];
            
            XCTAssertEqual(buttonNumber, expectedButtonNumber, @"%@", message);
            XCTAssertEqualObjects(buttonIdentifier, expectedIdentifier, @"%@", message);
            XCTAssertEqual(buttonValue, 1, @"%@", message);
            XCTAssertEqualObjects(controlIdentifier, expectedIdentifier, @"%@", message);
            XCTAssertEqual(controlValue, 1, @"%@", message);
            
            buttonIdentifier = nil;
            buttonNumber = -1;
            buttonValue = -1;
            controlIdentifier = nil;
            controlValue = -1;

            [mockDevice postInputValue:[[MockHIDValue alloc] initWithElement:element value:0]];
            
            XCTAssertEqual(buttonNumber, expectedButtonNumber, @"%@", message);
            XCTAssertEqualObjects(buttonIdentifier, expectedIdentifier, @"%@", message);
            XCTAssertEqual(buttonValue, 0, @"%@", message);
            XCTAssertEqualObjects(controlIdentifier, expectedIdentifier, @"%@", message);
            XCTAssertEqual(controlValue, 0, @"%@", message);
            
            buttonIdentifier = nil;
            buttonNumber = -1;
            buttonValue = -1;
            controlIdentifier = nil;
            controlValue = -1;
        }
    }
    
    // Test program switch
    
    IOHIDElementCookie programSwitchCookie = 6;
    
    if ( [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 15 ) {
        programSwitchCookie += 2;
    }
    
    MockHIDElement *element = [[MockHIDElement alloc] initWithCookie:programSwitchCookie];
    
    [mockDevice postInputValue:[[MockHIDValue alloc] initWithElement:element value:1]];
    
    NSString *programSwitchIdentifier = @"xkeys://1/1523/1029/0/button:32";
    
    XCTAssertEqualObjects(controlIdentifier, programSwitchIdentifier);
    XCTAssertEqual(controlValue, 1);
    XCTAssertEqual(programSwitchValue, 1);
    
    controlIdentifier = nil;
    controlValue = -1;
    programSwitchValue = -1;

    [mockDevice postInputValue:[[MockHIDValue alloc] initWithElement:element value:0]];
    
    XCTAssertEqualObjects(controlIdentifier, programSwitchIdentifier);
    XCTAssertEqual(controlValue, 0);
    XCTAssertEqual(programSwitchValue, 0);
    
    controlIdentifier = nil;
    controlValue = -1;
    programSwitchValue = -1;
}

- (void)testControllingTheDeviceLEDs {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    id<XkeysLED> greenLED = attachedDevice.greenLED;
    XCTAssertNotNil(greenLED);
    XCTAssertEqual(greenLED.state, XkeysLEDStateOff);
    
    id<XkeysLED> redLED = attachedDevice.redLED;
    XCTAssertNotNil(redLED);
    XCTAssertEqual(redLED.state, XkeysLEDStateOff);
    
    [mockDevice.outputReports removeAllObjects];
    
    const NSInteger bufferSize = 35;
    uint8_t buffer[bufferSize];
    bzero(buffer, sizeof(buffer));
    
    NSData *referenceData = nil;
    
    // Test Green LED On
    
    greenLED.state = XkeysLEDStateOn;
    
    buffer[0] = 179; // Index-based set LED command
    buffer[1] = 6; // Green LED index
    buffer[2] = 1; // LED On
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Green LED On"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test Green LED Flash

    greenLED.state = XkeysLEDStateFlash;
    
    bzero(buffer, sizeof(buffer));
    buffer[0] = 179; // Index-based set LED command
    buffer[1] = 6; // Green LED index
    buffer[2] = 2; // LED Flash
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Green LED Flash"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test Green LED Off

    greenLED.state = XkeysLEDStateOff;
    
    bzero(buffer, sizeof(buffer));
    buffer[0] = 179; // Index-based set LED command
    buffer[1] = 6; // Green LED index
    buffer[2] = 0; // LED Off
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Green LED Off"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test Red LED On
    
    redLED.state = XkeysLEDStateOn;
    
    buffer[0] = 179; // Index-based set LED command
    buffer[1] = 7; // Red LED index
    buffer[2] = 1; // LED On
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Red LED On"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
}

- (void)testControllingButtonBacklightState {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    [mockDevice.outputReports removeAllObjects];
    
    const NSInteger bufferSize = 35;
    uint8_t buffer[bufferSize];
    bzero(buffer, sizeof(buffer));
    
    NSData *referenceData = nil;
    NSString *message = nil;
    
    // Test individual buttons
    
    for ( uint8_t buttonNumber = 0 ; buttonNumber <= 29 ; buttonNumber++ ) {
        
        id<XkeysBlueRedButton> button = [attachedDevice buttonWithButtonNumber:(NSInteger)buttonNumber];
        if ( button == nil ) {
            continue;
        }
        
        id<XkeysLED> blueBacklight = button.blueLED;
        XCTAssertNotNil(blueBacklight, @"%ld", (NSInteger)buttonNumber);
        id<XkeysLED> redBacklight = button.redLED;
        XCTAssertNotNil(redBacklight, @"%ld", (NSInteger)buttonNumber);
        
        // Test Red Backlight On
        
        redBacklight.state = XkeysLEDStateOn;
        
        buffer[0] = 181; // Index-based Set Backlight command
        buffer[1] = (buttonNumber + 32); // Red Index
        buffer[2] = 1; // Backlight On
        
        referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
        message = [NSString stringWithFormat:@"Red #%ld Backlight On", (NSInteger)buttonNumber];
        [self compareDevice:mockDevice outputReportTo:referenceData message:message];
        [mockDevice.outputReports removeAllObjects];
        bzero(buffer, sizeof(buffer));
        
        // Test Red Backlight Flash
        
        redBacklight.state = XkeysLEDStateFlash;
        
        buffer[0] = 181; // Index-based Set Backlight command
        buffer[1] = (buttonNumber + 32); // Red Index
        buffer[2] = 2; // Backlight Flash
        
        referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
        message = [NSString stringWithFormat:@"Red #%ld Backlight Flash", (NSInteger)buttonNumber];
        [self compareDevice:mockDevice outputReportTo:referenceData message:message];
        [mockDevice.outputReports removeAllObjects];
        bzero(buffer, sizeof(buffer));
        
        // Test Red Backlight Off
        
        redBacklight.state = XkeysLEDStateOff;
        
        buffer[0] = 181; // Index-based Set Backlight command
        buffer[1] = (buttonNumber + 32); // Red Index
        buffer[2] = 0; // Backlight Off
        
        referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
        message = [NSString stringWithFormat:@"Red #%ld Backlight Off", (NSInteger)buttonNumber];
        [self compareDevice:mockDevice outputReportTo:referenceData message:message];
        [mockDevice.outputReports removeAllObjects];
        bzero(buffer, sizeof(buffer));
        
        // Test Blue Backlight On
        
        blueBacklight.state = XkeysLEDStateOn;
        
        buffer[0] = 181; // Index-based Set Backlight command
        buffer[1] = buttonNumber; // Blue Index
        buffer[2] = 1; // Backlight Off
        
        referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
        message = [NSString stringWithFormat:@"Blue #%ld Backlight On", (NSInteger)buttonNumber];
        [self compareDevice:mockDevice outputReportTo:referenceData message:message];
        [mockDevice.outputReports removeAllObjects];
        bzero(buffer, sizeof(buffer));
    }
    
    // Test all blue backlights on
    
    [attachedDevice setAllBacklightsWithColor:XkeysLEDColorBlue toState:XkeysLEDStateOn];
    
    buffer[0] = 182; // Row-based Set Backlight command
    buffer[1] = 0; // Blue Bank
    buffer[2] = 0xFF; // All rows on
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    message = [NSString stringWithFormat:@"All Blue Backlights On"];
    [self compareDevice:mockDevice outputReportTo:referenceData message:message];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test all blue backlights off
    
    [attachedDevice setAllBacklightsWithColor:XkeysLEDColorBlue toState:XkeysLEDStateOff];
    
    buffer[0] = 182; // Row-based Set Backlight command
    buffer[1] = 0; // Blue Bank
    buffer[2] = 0x00; // All rows off
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    message = [NSString stringWithFormat:@"All Blue Backlights Off"];
    [self compareDevice:mockDevice outputReportTo:referenceData message:message];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test all red backlights on
    
    [attachedDevice setAllBacklightsWithColor:XkeysLEDColorRed toState:XkeysLEDStateOn];
    
    buffer[0] = 182; // Row-based Set Backlight command
    buffer[1] = 1; // Red Bank
    buffer[2] = 0xFF; // All rows on
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    message = [NSString stringWithFormat:@"All Red Backlights On"];
    [self compareDevice:mockDevice outputReportTo:referenceData message:message];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test all red backlights off
    
    [attachedDevice setAllBacklightsWithColor:XkeysLEDColorRed toState:XkeysLEDStateOff];
    
    buffer[0] = 182; // Row-based Set Backlight command
    buffer[1] = 1; // Red Bank
    buffer[2] = 0x00; // All rows off
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    message = [NSString stringWithFormat:@"All Red Backlights Off"];
    [self compareDevice:mockDevice outputReportTo:referenceData message:message];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
}

- (void)testControllingButtonBacklightIntensity {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    [mockDevice.outputReports removeAllObjects];
    
    const NSInteger bufferSize = 35;
    uint8_t buffer[bufferSize];
    bzero(buffer, sizeof(buffer));
    
    NSData *referenceData = nil;
    
    // Test raw intensity
    
    [attachedDevice setRawIntensityOfBacklightsToBlue:0x12 red:0x34];
    
    buffer[0] = 187; // Set Backlight Intensity command
    buffer[1] = 0x12; // Blue intensity
    buffer[2] = 0x34; // Red intensity
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Set raw backlight intensity"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test calibrated intensity 1.0
    
    [attachedDevice setCalibratedIntensityOfBacklightsToBlue:1.0 red:1.0];
    
    buffer[0] = 187; // Set Backlight Intensity command
    buffer[1] = 0xFF; // Blue intensity
    buffer[2] = 0xFF; // Red intensity
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Set backlight intensity 1.0"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
    
    // Test calibrated intensity 0.25 / 0.75
    
    [attachedDevice setCalibratedIntensityOfBacklightsToBlue:0.25 red:0.75];
    
    buffer[0] = 187; // Set Backlight Intensity command
    buffer[1] = 0x40; // Blue intensity
    buffer[2] = 0xBF; // Red intensity
    
    referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    [self compareDevice:mockDevice outputReportTo:referenceData message:@"Set backlight intensity 0.25 / 0.75"];
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
}

- (void)testChangingDeviceProductID {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];

    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    [mockDevice.outputReports removeAllObjects];
    
    const NSInteger bufferSize = 35;
    uint8_t buffer[bufferSize];
    bzero(buffer, sizeof(buffer));
    
    NSArray<NSNumber *> *pids = @[ @1027, @1028, @1029, @1249 ];
    
    // Test
    
    for ( uint8_t mode = 0 ; mode <= 3 ; mode++ ) {
        
        attachedDevice.productID = [pids[mode] integerValue];
        
        buffer[0] = 204; // Set Product ID command
        buffer[1] = mode; // PID Mode
        
        NSData *referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
        NSString *message = [NSString stringWithFormat:@"Product ID = %@", pids[mode]];
        
        [self compareDevice:mockDevice outputReportTo:referenceData message:message];
        
        [mockDevice.outputReports removeAllObjects];
        bzero(buffer, sizeof(buffer));
    }
}

- (void)testChangingDeviceUnitID {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    [mockDevice.outputReports removeAllObjects];
    
    const NSInteger bufferSize = 35;
    uint8_t buffer[bufferSize];
    bzero(buffer, sizeof(buffer));
    
    XCTAssertTrue(attachedDevice.unitID != 255);
    
    // Test
    
    for ( NSInteger uid = 0xFF ; uid >= 0 ; uid-- ) {
        
        attachedDevice.unitID = uid;
        
        buffer[0] = 189; // Set Unit ID command
        buffer[1] = (uint8_t)uid; // Unit ID
        
        NSData *referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
        NSString *message = [NSString stringWithFormat:@"Unit ID = %ld", uid];
        
        [self compareDevice:mockDevice outputReportTo:referenceData message:message];
        
        [mockDevice.outputReports removeAllObjects];
        bzero(buffer, sizeof(buffer));
    }
}

- (void)testWritingBacklightStateToEEPROM {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    MockXK24 *mockDevice = [[MockXK24 alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys24> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys24)] ) {
            attachedDevice = (id<Xkeys24>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXK24);
    
    [mockDevice.outputReports removeAllObjects];
    
    const NSInteger bufferSize = 35;
    uint8_t buffer[bufferSize];
    bzero(buffer, sizeof(buffer));
    
    // Test
    
    [attachedDevice writeBacklightStateToEEPROM];
    
    buffer[0] = 199; // Set Unit ID command
    buffer[1] = 1; // Non-zero value
    
    NSData *referenceData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO];
    NSString *message = [NSString stringWithFormat:@"Write to EEPROM"];
    
    [self compareDevice:mockDevice outputReportTo:referenceData message:message];
    
    [mockDevice.outputReports removeAllObjects];
    bzero(buffer, sizeof(buffer));
}

- (void)compareDevice:(MockHIDDevice *)device outputReportTo:(NSData *)referenceData message:(NSString *)message {
    
    MockHIDOutputReport *outputReport = device.outputReports.firstObject;
    XCTAssertNotNil(outputReport, @"%@", message);
    XCTAssertEqual(device.outputReports.count, 1, @"%@", message);
    XCTAssertNotNil(outputReport, @"%@", message);
    XCTAssertEqual(outputReport.reportID, 0, @"%@", message);
    XCTAssertEqual(outputReport.reportType, kIOHIDReportTypeOutput, @"%@", message);
    XCTAssertEqualObjects(outputReport.reportData, referenceData, @"%@", message);
}

@end
