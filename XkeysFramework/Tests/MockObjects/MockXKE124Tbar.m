//
//  MockXKE124Tbar.m
//  XkeysFrameworkTests
//
//  Created by Ken Heglund on 10/27/17.
//  Copyright © 2017 P.I. Engineering. All rights reserved.
//

@import IOKit.hid;

#import "MockXKE124Tbar.h"

@implementation MockXKE124Tbar

// MARK: - MockHIDDevice overrides

- (instancetype)init {
    return [super initWithProductID:1278];
}

- (NSInteger)deviceUsagePage {
    return kHIDPage_Consumer;
}

- (NSInteger)deviceUsage {
    return kHIDUsage_Csmr_ConsumerControl;
}

- (IOReturn)setReport:(const uint8_t *)report length:(CFIndex)reportLength reportID:(CFIndex)reportID type:(IOHIDReportType)reportType {
    
    IOReturn result = [super setReport:report length:reportLength reportID:reportID type:reportType];
    if ( result != kIOReturnSuccess ) {
        return result;
    }
    
    if ( self.inputReportBuffer == NULL ) {
        return kIOReturnSuccess;
    }
    
    if ( report[0] == 177 && reportLength == 35 && [MockXkeysDevice areZerosInReport:report fromIndex:1 toIndex:34] && self.inputReportBufferLength >= 36 ) {
        
        // Generate Data command
        bzero(self.inputReportBuffer, self.inputReportBufferLength);
        self.inputReportBuffer[0] = self.unitID;
        self.inputReportBuffer[1] = 2; // Indicates this response was requested with the Generate Data command
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postInputReportOfLength:36 withType:kIOHIDReportTypeInput reportID:0];
        });
    }
    else if ( report[0] == 214 && reportLength == 35 && [MockXkeysDevice areZerosInReport:report fromIndex:1 toIndex:34] ) {
        
        uint8_t ledState = (self.greenLEDState ? 0x40 : 0x00) | (self.redLEDState ? 0x80 : 0x00);
        
        // Generate Descriptor
        bzero(self.inputReportBuffer, self.inputReportBufferLength);
        self.inputReportBuffer[0] = self.unitID;
        self.inputReportBuffer[1] = 214; // Indicates this response was requested with the Request Descriptor command
        self.inputReportBuffer[9] = ledState;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postInputReportOfLength:36 withType:kIOHIDReportTypeInput reportID:0];
        });
    }
    
    return kIOReturnSuccess;
}

@end
