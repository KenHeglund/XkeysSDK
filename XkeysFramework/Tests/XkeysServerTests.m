//
//  XkeysFrameworkTests.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/25/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import <XCTest/XCTest.h>

#import "MockHIDElement.h"
#import "MockHIDManager.h"
#import "MockHIDValue.h"
#import "MockXKE124Tbar.h"
#import "XkeysServer+Private.h"
#import "XkeysTestHIDSystem.h"

@interface XkeysFrameworkTests : XCTestCase

@end

@implementation XkeysFrameworkTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatTheServerDoesNotConnectToTheHIDSystemUntilItIsOpened {
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    
    XCTAssertNil(hidSystem.hidManager);
    
    [server open:XkeysServerOptionNone];
    
    XCTAssertNotNil(hidSystem.hidManager);
    XCTAssertEqual(hidSystem.hidManager.isOpen, YES);
    XCTAssertNotEqual(hidSystem.hidManager.scheduledRunLoop, NULL);
    XCTAssertNotEqual(hidSystem.hidManager.scheduledRunLoopMode, NULL);
    XCTAssertNotEqual(hidSystem.hidManager.matchingCallback, NULL);
    
    [server close];
    
    XCTAssertEqual(hidSystem.hidManager.isOpen, NO);
    XCTAssertEqual(hidSystem.hidManager.scheduledRunLoop, NULL);
    XCTAssertEqual(hidSystem.hidManager.scheduledRunLoopMode, NULL);
    XCTAssertEqual(hidSystem.hidManager.matchingCallback, NULL);
}

- (void)testThatTheServerCallsTheCorrectCallbacksWhenADeviceIsAttached {
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    XCTestExpectation *detachExpectation = [self expectationWithDescription:@"Waiting for onDeviceDetachPerform: callback"];
    __block id<XkeysDevice> attachedDevice = nil;
    __block id<XkeysDevice> detachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        attachedDevice = xkeysDevice;
        [attachExpectation fulfill];
    }];
    
    [server onDeviceDetachPerform:^(id<XkeysDevice> xkeysDevice) {
        detachedDevice = xkeysDevice;
        [detachExpectation fulfill];
    }];
    
    [server open:XkeysServerOptionNone];
    
    MockXKE124Tbar *mockDevice = [[MockXKE124Tbar alloc] init];
    mockDevice.unitID = 123;
    
    XCTAssertNotNil(hidSystem.hidManager);
    [hidSystem.hidManager attachDevice:mockDevice];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.unitID, mockDevice.unitID);

    [hidSystem.hidManager detachDevice:mockDevice];
    
    [self waitForExpectations:@[detachExpectation] timeout:1.0];
    
    XCTAssertNotNil(detachedDevice);
    XCTAssertEqual(detachedDevice.unitID, mockDevice.unitID);
}

- (void)testThatEventHandlersAreEffectivePriorToDeviceAttachment {
    
    // Setup
    
    XkeysTestHIDSystem *hidSystem = [[XkeysTestHIDSystem alloc] init];
    XkeysServer *server = [[XkeysServer alloc] initWithHIDSystem:hidSystem];
    [server open:XkeysServerOptionNone];
    
    __block NSString *controlIdentifier = @"";
    __block NSInteger controlValue = NSIntegerMax;
    
    [server onControlValueChange:@"xkeys://1/1523/1278/0/slider:0" perform:^BOOL(id<XkeysControl> control) {
        controlIdentifier = control.identifier;
        controlValue = control.currentValue;
        return YES;
    }];
    
    __block NSString *anyControlIdentifier = @"";
    __block NSInteger anyControlValue = NSIntegerMax;
    
    [server onAnyControlValueChangePerform:^BOOL(id<XkeysControl> control) {
        anyControlIdentifier = control.identifier;
        anyControlValue = control.currentValue;
        return YES;
    }];
    
    MockXKE124Tbar *mockDevice = [[MockXKE124Tbar alloc] init];
    [hidSystem.hidManager attachDevice:mockDevice];
    
    XCTestExpectation *attachExpectation = [self expectationWithDescription:@"Waiting for onDeviceAttachPerform: callback"];
    __block id<Xkeys124Tbar> attachedDevice = nil;
    
    [server onDeviceAttachPerform:^(id<XkeysDevice> xkeysDevice) {
        if ( [xkeysDevice conformsToProtocol:@protocol(Xkeys124Tbar)] ) {
            attachedDevice = (id<Xkeys124Tbar>)xkeysDevice;
            [attachExpectation fulfill];
        }
    }];
    
    [self waitForExpectations:@[attachExpectation] timeout:1.0];
    
    XCTAssertNotNil(attachedDevice);
    XCTAssertEqual(attachedDevice.model, XkeysModelXKE124Tbar);
    
    // Test
    
    IOHIDElementCookie tbarCookie = 33;
    
    if ( [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 15 ) {
        tbarCookie += 2;
    }
    
    MockHIDElement *element = [[MockHIDElement alloc] initWithCookie:tbarCookie];
    
    const NSInteger eventValue = 123;
    MockHIDValue *value = [[MockHIDValue alloc] initWithElement:element value:eventValue];
    
    [mockDevice postInputValue:value];
    
    XCTAssertEqualObjects(controlIdentifier, attachedDevice.tbar.identifier);
    XCTAssertEqual(controlValue, eventValue);
    
    XCTAssertEqualObjects(anyControlIdentifier, attachedDevice.tbar.identifier);
    XCTAssertEqual(anyControlValue, eventValue);
}

@end
