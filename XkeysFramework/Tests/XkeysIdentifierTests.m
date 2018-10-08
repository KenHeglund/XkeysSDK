//
//  XkeysIdentifierTests.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 11/1/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import XkeysKit;

#import <XCTest/XCTest.h>

#import "XkeysIdentifiers.h"
#import "XkeysOutput.h"

#import "MockXKE124Tbar.h"

@interface XkeysIdentifierTests : XCTestCase

@end

@implementation XkeysIdentifierTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTheIdentifierThatIsGeneratedForAKnownDevice {
    
    MockXKE124Tbar *mockDevice = [[MockXKE124Tbar alloc] init];
    mockDevice.unitID = 123;
    
    NSString *firstIdentifier = [XkeysIdentifiers identifierForUnit:(XkeysUnit<XkeysDevice> *)mockDevice];
    XCTAssertEqualObjects(firstIdentifier, @"xkeys://1/1523/1278/123");
    
    mockDevice.unitID = 234;
    
    NSString *secondIdentifier = [XkeysIdentifiers identifierForUnit:(XkeysUnit<XkeysDevice> *)mockDevice];
    XCTAssertEqualObjects(secondIdentifier, @"xkeys://1/1523/1278/234");
}

- (void)testThatADeviceIdentifierMatchesCorrectly {
    
    MockXKE124Tbar *mockXKETbar1 = [[MockXKE124Tbar alloc] init];
    mockXKETbar1.productID = 1275;
    mockXKETbar1.unitID = 123;
    
    MockXKE124Tbar *mockXKETbar2 = [[MockXKE124Tbar alloc] init];
    mockXKETbar2.productID = 1278;
    mockXKETbar2.unitID = 234;
    
    MockXKE124Tbar *mockXKETbar3 = [[MockXKE124Tbar alloc] init];
    mockXKETbar3.productID = 1278;
    mockXKETbar3.unitID = 123;

    MockXkeysDevice *mockXkeysUnknownDevice = [[MockXkeysDevice alloc] initWithProductID:4321];
    mockXkeysUnknownDevice.unitID = 123;
    
    NSString *unitIDSpecificIdentifier = @"xkeys://1/1523/1278/123";
    NSString *unitIDIndependentIdentifier = @"xkeys://1/1523/1278/*";

    // Default match options
    
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar1]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar2]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar3]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXkeysUnknownDevice]);
    
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar1]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar2]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar3]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXkeysUnknownDevice]);
    
    // Require ProductID match
    
    [XkeysIdentifiers setProductIDMatchRequired:YES];
    
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar1]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar2]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar3]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXkeysUnknownDevice]);
    
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar1]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar2]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar3]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXkeysUnknownDevice]);
    
    // Require UnitID match
    
    [XkeysIdentifiers setProductIDMatchRequired:NO];
    [XkeysIdentifiers setUnitIDMatchRequired:YES];
    
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar1]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar2]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar3]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDSpecificIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXkeysUnknownDevice]);
    
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar1]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar2]);
    XCTAssertTrue([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXKETbar3]);
    XCTAssertFalse([XkeysIdentifiers identifier:unitIDIndependentIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockXkeysUnknownDevice]);
}

- (void)testExtractingADeviceIdentifierWithAndWithoutAUnitID {
    
    NSString *controlIdentifier = @"xkeys://1/1523/1234/234/controlSuffix";
    
    NSString *deviceIdentifier1 = [XkeysIdentifiers deviceIdentifierFromIdentifier:controlIdentifier preservingUnitID:YES];
    XCTAssertEqualObjects(deviceIdentifier1, @"xkeys://1/1523/1234/234");
    
    NSString *deviceIdentifier2 = [XkeysIdentifiers deviceIdentifierFromIdentifier:controlIdentifier preservingUnitID:NO];
    XCTAssertEqualObjects(deviceIdentifier2, @"xkeys://1/1523/1234/*");
}

- (void)testThatInvalidIdentifiersAreRejected {
    
    NSString *identifierWithBadPrefix = @"zkeys://1/1523/1234/234/controlSuffix";
    XCTAssertNil([XkeysIdentifiers deviceIdentifierFromIdentifier:identifierWithBadPrefix preservingUnitID:NO]);
    
    NSString *identifierWithBadVersion = @"xkeys://2/1523/1234/234/controlSuffix";
    XCTAssertNil([XkeysIdentifiers deviceIdentifierFromIdentifier:identifierWithBadVersion preservingUnitID:NO]);
    
    NSString *identifierWithBadVendorID = @"xkeys://1/4321/1234/234/controlSuffix";
    XCTAssertNil([XkeysIdentifiers deviceIdentifierFromIdentifier:identifierWithBadVendorID preservingUnitID:NO]);
}

- (void)testThatIdentifierLettercaseIsIgnored {
    
    MockXKE124Tbar *mockDevice = [[MockXKE124Tbar alloc] init];
    mockDevice.unitID = 123;
    
    NSString *uppercaseIdentifier = @"XKEYS://1/1523/1278/123";
    XCTAssertTrue([XkeysIdentifiers identifier:uppercaseIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockDevice]);
    
    NSString *mixedcaseIdentifier = @"xKeys://1/1523/1278/123";
    XCTAssertTrue([XkeysIdentifiers identifier:mixedcaseIdentifier matchesUnit:(XkeysUnit<XkeysDevice> *)mockDevice]);
}

- (void)testThatOutputIdentifiersAreCorrect {
    
    MockXKE124Tbar *mockDevice = [[MockXKE124Tbar alloc] init];
    mockDevice.unitID = 123;
    
    XkeysOutput *output = [[XkeysOutput alloc] initWithDevice:(XkeysUnit<XkeysDevice> *)mockDevice name:@"unused" controlIndex:7];
    NSString *outputIdentifier = @"xkeys://1/1523/1278/123/output:7";
    XCTAssertEqualObjects(output.identifier, outputIdentifier);
}

@end
